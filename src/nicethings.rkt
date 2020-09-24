#lang racket/base

(require racket/file
         racket/list
         racket/match
         racket/string)

;; ------------------------------------------------
;; Constants
;; ------------------------------------------------
(define help-command-1      "help")
(define help-command-2      "--help")
(define help-command-3      "-h")
(define init-command        "init")
(define ls-command          "ls")
(define rm-command          "rm")
(define add-command         "add")
(define program-name        "nicethings")
(define program-file        (string-append "." program-name))
(define program-path        (build-path (find-system-path 'home-dir) program-file))
(define program-permissions 420) ;; 644/-rw-r--r-- permissions
(define newline             "\n")
(define double-newline      "\n\n")

;; ------------------------------------------------
;; Messages
;; ------------------------------------------------
(define messages
  (hash
    'error-too-many-arguments
    (format (string-append "Error: Too many arguments." newline
                           "Try running '~a ~a' for more information.")
            program-name
            help-command-1)

    'error-incorrect-usage
    (format (string-append "Error: Incorrect usage." newline
                           "Try running '~a ~a' for more information.")
            program-name
            help-command-1)

    'error-file-already-exists
    (format "Error: The file '~a' already exists." program-path)

    'error-fake-file-exists
    (format (string-append "Error: The directory '~a' exists." newline
                           "Try moving, renaming, or deleting this directory.")
            program-path)

    'error-file-doesnt-exist
    (format (string-append "Error: '~a' doesn't exist." newline
                           "Try running '~a ~a'.")
            program-path
            program-name
            init-command)

    'error-item-not-found
    "Error: Item not found."


    'warning-permissions
    (format (string-append "Warning: The permissions on your '~a' file are incorrect." newline
                           "Other users on this host may be able to read your file." newline
                           "Try running 'chmod 600 ~a' to fix this." newline)
            program-path
            program-path)

    'init-cancelled
    (format "Cancelled the creation of '~a'." program-path)

    'init-prompt
    (format (string-append "~a will create '~a'." newline
                           "Is this okay? [y/n]")
            program-name
            program-path)

    'file-created
    (format "Successfully created ~a." program-path)

    'empty-list
    "There is nothing in your list."))

(define formatees
  (hash
    'error-not-an-option
    (string-append "Error: '~a' is not an option." newline
                   "Please choose 'y' or 'n'.")

    'error-not-a-number
    (string-append "Error: '~a' is not a number.")

    'added
    "Added '~a' to your list."

    'removed
    "Removed '~a' from your list."))

;; ------------------------------------------------
;; helpers
;; ------------------------------------------------
(define (messages-ref key)
  (hash-ref messages key))

(define (formatees-ref key)
  (hash-ref formatees key))

(define (displayln-messages-ref key)
  (let ([message (messages-ref key)])
    (displayln message)))

(define (displayln-formatees-ref key string)
  (let* ([formatee           (formatees-ref key)]
         [formatee-formatted (format formatee string)])
    (displayln formatee-formatted)))

(define (create-file string)
  (close-output-port
    (open-output-file string)))

(define (has-program-permissions? string)
  (equal? program-permissions (file-or-directory-permissions string 'bits)))

;; ------------------------------------------------
;; Check conditions
;; ------------------------------------------------
(define (check-conditions)
  (cond
    [(directory-exists? program-path)
     (begin (displayln-messages-ref 'error-fake-file-exists)
            (exit))]

    [(not (file-exists? program-path))
     (begin (displayln-messages-ref 'error-file-doesnt-exist)
            (exit))]

    [(not (has-program-permissions? program-path))
     (displayln-messages-ref 'warning-permissions)]

    [else 'do-nothing]))


;; ------------------------------------------------
;; init
;; ------------------------------------------------
(define (init/create-file)
  (create-file program-path)
  (file-or-directory-permissions program-path
                                 program-permissions)
  (displayln-messages-ref 'file-created))

(define (init/cancel)
  (displayln-messages-ref 'init-cancelled)
  (exit))

(define (init/prompt)
  (displayln-messages-ref 'init-prompt)
  (display "> ")
  (let* ([input        (read-line)]
         [input-symbol (string->symbol input)])
    (case input-symbol
      ['y   (init/create-file)]
      ['n   (init/cancel)]
      [else (displayln-formatees-ref 'error-not-an-option input)])))

(define (init)
  (cond
    [(file-exists? program-path)
     (displayln-messages-ref 'error-file-already-exists)]

    [(directory-exists? program-path)
     (displayln-messages-ref 'error-fake-file-exists)]

    [else (init/prompt)]))

;; ------------------------------------------------
;; ls
;; ------------------------------------------------
(define (ls/display-list listof-items)
  ;; The add1 in the first binding starts the
  ;; listof-numbers at 1 instead of 0 to make the
  ;; list numbering more human-friendly
  (let* ([listof-numbers        (map add1 (range (length listof-items)))]
         [listof-number-strings (map number->string listof-numbers)]
         [combine-lists         (lambda (a b) (string-append a ". " b))]
         [listof-numbered-items (map combine-lists
                                     listof-number-strings
                                     listof-items)])
    (for ([item listof-numbered-items])
         (displayln item))))

(define (ls)
  (check-conditions)
  (let ([listof-items (file->lines program-path)])
    (if (null? listof-items)
        (displayln-messages-ref 'empty-list)
        (ls/display-list listof-items))))

;; ------------------------------------------------
;; rm
;; ------------------------------------------------
(define (rm/remove-item listof-items item-number)
  (let* ([item-to-remove    (list-ref listof-items item-number)]
         [list-without-item (remove item-to-remove listof-items)])
    (display-lines-to-file list-without-item
                           program-path
                           #:exists 'truncate)
    (displayln-formatees-ref 'removed item-to-remove)))

(define (rm/process-string string)
  (let* ([listof-items (file->lines program-path)]
         [item-number      (string->number string)]
         ;; Subtract 1 from the user's original number,
         ;; because we want to convert the number from
         ;; human numbers (1 2 3) to index numbers
         ;; (0 1 2)
         [item-number-sub1 (sub1 item-number)]
         [list-length      (length listof-items)])
    (if (and (not (null? listof-items))
             (number? item-number)
             (positive? item-number)
             ;; Don't allow numbers that are equal to
             ;; or greater than list-length, because
             ;; the list index starts at 0
             ;;
             ;; Example:
             ;; Length of (1 2 3) = 3
             ;;
             ;; To reference the highest number, we
             ;; use (list-ref (1 2 3) 2)
             (< item-number-sub1 list-length))
        (rm/remove-item listof-items item-number-sub1)
        (displayln-messages-ref 'error-item-not-found))))

(define (rm string)
  (check-conditions)
  (if (string->number string)
      (rm/process-string string)
      (displayln-formatees-ref 'error-not-a-number string)))

;; ------------------------------------------------
;; add
;; ------------------------------------------------
(define (add string)
  (check-conditions)
  ;; The removing and adding of the '\n' is to
  ;; ensure only one '\n' exists at the end of the
  ;; item to be added.
  (let* ([string-no-newline (string-replace string "\n" "")]
         [string-newline    (string-append string-no-newline "\n")])
    (display-to-file string-newline
                     program-path
                     #:exists 'append)
    (displayln-formatees-ref 'added string-no-newline)))

;; ------------------------------------------------
;; random message
;; ------------------------------------------------
(define (random-message/append-program-file home-directory)
  (build-path home-directory program-file))

(define (random-message)
  (let* ([root                        (find-system-path 'sys-dir)] ;; /
         [root-home                   (build-path root "home")]    ;; /home
         ;; `#:build? #t` Builds full paths for all items listed in /home/
         [listof-home-directories     (directory-list root-home #:build? #t)]
         [listof-nicethings-paths     (map random-message/append-program-file listof-home-directories)]
         [directories-with-nicethings (filter file-exists? listof-nicethings-paths)]
         [directories-with-644        (filter has-program-permissions? directories-with-nicethings)]
         [listof-nicethings           (apply append (map file->lines directories-with-644))]
         [list-length                 (length listof-nicethings)])
    (when (not (zero? list-length))
      (let* ([random-number    (random list-length)]
             [random-nicething (list-ref listof-nicethings random-number)])
        (displayln random-nicething)))))

;; ------------------------------------------------
;; help
;; ------------------------------------------------
(define (help)
  (displayln
    (string-append
    "Usage:" newline
    (format "  ~a [<command>] [<args>]" program-name)
    double-newline

    "Commands:" newline
            "  No command - Displays a random nicething from a random user." newline
    (format "  ~a - Creates a file in ~a, which allows you to contribute to the town-wide list of nicethings."
            init-command
            program-path) newline
    (format "  ~a - Adds a nicething to your list." add-command) newline
    (format "  ~a - Prints a numbered list of the nicethings you've added." ls-command) newline
    (format "  ~a - Removes a nicething from your list." rm-command)
    double-newline

    "Examples:" newline
    (format "  ~a" program-name) newline
    (format "  ~a ~a" program-name init-command) newline
    (format "  ~a ~a \"You are wonderful\"" program-name add-command) newline
    (format "  ~a ~a" program-name ls-command) newline
    (format "  ~a ~a 2" program-name rm-command))))

(define (process-args vectorof-args)
  (match vectorof-args
    [(or (vector (== help-command-1))
         (vector (== help-command-2))
         (vector (== help-command-3))) (help)]
    [(vector (== ls-command))          (ls)]
    [(vector (== init-command))        (init)]
    [(vector (== add-command) a)       (add a)]
    [(vector (== rm-command)  a)       (rm  a)]
    [(vector _ ...)                    (displayln-messages-ref 'error-incorrect-usage)]
    [_                                 (random-message)]))

(define (main vectorof-args)
  (process-args vectorof-args))

(main (current-command-line-arguments))

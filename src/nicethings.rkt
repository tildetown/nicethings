#lang racket/base

(require racket/file
         racket/list
         racket/match
         racket/string)

;; ------------------------------------------------
;; values
;; ------------------------------------------------
(define nicethings-string     ".nicethings")
(define nicethings-path       (build-path home-directory nicethings-string))

;; ------------------------------------------------
;; messages
;; ------------------------------------------------
(define messages
  (hash
   'not-found                "> '~a' wasn't found."
   'item-not-found           (list "> Error: Item not found."
                                   "> Try using the 'ls' command to see which number correlates to which message in your list.")
   'empty-list               "> Your list of nice things is empty."
   'not-found-prompt         "> You will need it to add new messages to nicethings.\n> Do you want to create it? [y/n]\n> "
   'wrong-permissions        "> '~a''s permissions are incorrect."
   'wrong-permissions-prompt "> You will need the permissions to be fixed before using nicethings.\n> Do you want to fix them? [y/n]\n> "
   'fake-file-found          "> The directory '~a' was found.\n> Please move this file somewhere else before using nicethings."
   'try                      (list "> For usage help, try running the following command:"
                                   "nicethings --help")
   'cancel                   "> Cancelled."
   'file-created             "> '~a' was successfully created."
   'permissions-fixed        "> '~a''s permissions were successfully fixed."
   'not-an-option            "> Error: '~a' is not an option."
   'add-expected-arg         (list "> Error: Found 'add', but no arguments were found."
                                   "> The 'add' command expects one quoted argument after it."
                                   "> Example: nicethings add \"You are beautiful\".")
   'rm-expected-arg          (list "> Error: Found 'rm', but no arguments were found."
                                   "> The 'rm' command expects one number as an argument after it."
                                   "> Example: nicethings rm 2"
                                   "> Note: You may need to use the 'ls' command to see which number correlates to which message in your list.")
   'ls-expected-no-args      (list "> Error: Found 'ls', but also found other arguments."
                                   "> The 'ls' command expects no arguments after it."
                                   "> Example:"
                                   "nicethings ls")
   'added                    "> Added '~a' to your list of nice things."
   'removed                  "> Removed '~a' from your list of nice things."))

;; ------------------------------------------------
;; helpers
;; ------------------------------------------------
(define (displayln-for . strings)
  (for ([string strings])
    (displayln string)))

(define (display-message-list key)
  (apply displayln-for (messages-ref key)))

(define-syntax-rule (displayln-format str ...)
  (displayln (format str ...)))

(define (messages-ref key)
  (hash-ref messages key))

(define (file-has-420-permissions? file)
  (equal? 420 (file-or-directory-permissions file 'bits)))

;; ------------------------------------------------
;; repair
;; ------------------------------------------------
(define (repair/not-an-option user-input)
  (displayln-format (messages-ref 'not-an-option) user-input)
  (exit))

(define (repair/cancel)
  (displayln (messages-ref 'cancel))
  (exit))

(define (repair/fix-permissions)
  (file-or-directory-permissions nicethings-path 420)
  (displayln-format (messages-ref 'permissions-fixed) nicethings-path))

(define (repair/wrong-permissions)
  (display (messages-ref 'wrong-permissions-prompt))
  (let ([user-input (read-line)])
    (case (string->symbol user-input)
      ['y   (repair/fix-permissions)]
      ['n   (repair/cancel)]
      [else (repair/not-an-option user-input)])))

(define (repair/create-file)
  (close-output-port (open-output-file nicethings-path))
  (file-or-directory-permissions nicethings-path 420)
  (displayln-format (messages-ref 'file-created) nicethings-path))

(define (repair/not-found)
  (display (messages-ref 'not-found-prompt))
  (let ([user-input (read-line)])
    (case (string->symbol user-input)
      ['y   (repair/create-file)]
      ['n   (repair/cancel)]
      [else (repair/not-an-option user-input)])))

(define (repair)
  (cond
    ;; Check for a "fake" '.nicethings' file, which is a directory named '.nicethings'
    [(directory-exists? nicethings-path)
     (begin (displayln-format (messages-ref 'fake-file-found) nicethings-path)
            (exit))]
    ;; Check for a missing '.nicethings' file
    [(not (file-exists? nicethings-path))
     (begin (displayln-format (messages-ref 'not-found) nicethings-path)
            (repair/not-found))]
    ;; Check for incorrect permissions on '.nicethings' file
    [(not (file-has-420-permissions? nicethings-path))
     (begin (displayln-format (messages-ref 'wrong-permissions) nicethings-path)
            (repair/wrong-permissions))]
    [else 'do-nothing]))

;; ------------------------------------------------
;; ls
;; ------------------------------------------------
(define (ls/display-list listof-nicethings)
  ;; add1 starts the listof-numbers at 1 instead of 0
  (let* ([listof-numbers        (map add1 (range (length listof-nicethings)))]
         [listof-number-strings (map number->string listof-numbers)]
         [combine-lists         (lambda (a b) (string-append a ". " b))]
         [listof-numbered-items (map combine-lists
                                     listof-number-strings
                                     listof-nicethings)])
    (for ([item listof-numbered-items])
      (displayln item))))

(define (ls)
  (repair)
  (let ([listof-nicethings (file->lines nicethings-path)])
    (if (null? listof-nicethings)
        (displayln (messages-ref 'empty-list))
        (ls/display-list listof-nicethings))))

;; ------------------------------------------------
;; rm
;; ------------------------------------------------
(define (rm/remove-item listof-nicethings item-number)
  (let* ([item-to-remove    (list-ref listof-nicethings item-number)]
         [list-without-item (remove item-to-remove listof-nicethings)])
    (display-lines-to-file list-without-item
                           nicethings-path
                           #:exists 'truncate)
    (displayln-format (messages-ref 'removed) item-to-remove)))

(define (rm string)
  (repair)
  (let* ([listof-nicethings (file->lines nicethings-path)]
         ;; subtract 1 because the index starts at
         ;; 0 under the hood, but the numbers presented from 'ls'
         ;; start at 1.
         [item-number       (string->number string)]
         [item-number-sub1  (sub1 item-number)]
         [list-length       (length listof-nicethings)])
    (if (and (not (null? listof-nicethings))
             (number? item-number)
             (positive? item-number)
             ;; 1 less than length, because we want to
             ;; remove the index number, which is one less
             ;; than the item the user chose
             ;; Example:
             ;; We have a list length of 3:
             ;; '(1 2 3)
             ;; `list-ref` in rm/remove-item above
             ;; uses an index that starts at 0, so
             ;; the index of the numbers above are:
             ;; '(0 1 2)
             ;; The 2 is the last index number in a
             ;; list of length 3, which is what we
             ;; want, because if you try to remove
             ;; an index larger than 2, such as the
             ;; list length 3, then that would be
             ;; an error
             (< item-number-sub1 list-length))
        (rm/remove-item listof-nicethings item-number-sub1)
        (display-message-list 'item-not-found))))

;; ------------------------------------------------
;; add
;; ------------------------------------------------
;; The string-cleaned and -remade is incase there
;; are multiple newline characters. This ensures
;; there is only one newline character.
(define (add string)
  (repair)
  (let* ([string-no-newline (string-replace string "\n" "")]
         [string-newline    (string-append string-no-newline "\n")])
    (display-to-file string-newline
                     nicethings-path
                     #:exists 'append)
    (displayln-format (messages-ref 'added) string-no-newline)))

;; ------------------------------------------------
;; random message
;; ------------------------------------------------
(define (random-message/append-nicethings-file home-directory)
  (build-path home-directory nicethings-string))

(define (random-message)
  (let* ([root                        (find-system-path 'sys-dir)]
         [root-home                   (build-path root "home")]
         [listof-homes                (directory-list root-home #:build? #t)]
         [paths-to-nicethings         (map random-message/append-nicethings-file listof-homes)]
         [directories-with-nicethings (filter file-exists? paths-to-nicethings)]
         [directories-with-420        (filter file-has-420-permissions? directories-with-nicethings)]
         [listof-nicethings           (apply append (map file->lines directories-with-420))]
         [list-length                 (length listof-nicethings)])
    (when (not (zero? list-length))
      (let* ([random-number    (random list-length)]
             [random-nicething (list-ref listof-nicethings random-number)])
        (displayln random-nicething)))))

;; ------------------------------------------------
;; help
;; ------------------------------------------------
(define (help)
  (displayln-for
   "Usage:"
   "  nicethings [<command>] [<args>]"
   ""
   "Commands:"
   "  No command - Print a random nice thing."
   "  add        - Add a message to the list of nice things."
   "  ls         - Print a numbered list of the nice things you have added."
   "  rm         - Remove a message you have added from the list of nice things."
   ""
   "Examples:"
   "  nicethings"
   "  add \"You are beautiful\""
   "  ls"
   "  rm 2"))

(define (process-args vectorof-args)
  (define (args-ref number)
    (vector-ref vectorof-args number))
  (match vectorof-args
    ;; Proper usage
    [(or '#("-h")
         '#("--help")
         '#("help"))  (help)]
    [(vector "add" _) (add (args-ref 1))]
    [(vector "rm" _)  (rm (args-ref 1))]
    [(vector "ls")    (ls)]
    [(vector)         (random-message)]
    ;; Improper usage (Give the user hints if part of the usage is correct)
    [(vector "ls" _)  (display-message-list 'ls-expected-no-args)]
    [(vector "add")   (display-message-list 'add-expected-arg)]
    [(vector "rm")    (display-message-list 'rm-expected-arg)]
    [(vector _ ...)   (display-message-list 'try)]))

(define (main vectorof-args)
  (process-args vectorof-args))

(main (current-command-line-arguments))

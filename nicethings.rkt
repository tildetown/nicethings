#lang racket

;; ------------------------------------------------
;; values
;; ------------------------------------------------
(define nicethings-string     ".nicethings")
(define home-directory        (find-system-path 'home-dir))
(define listof-home-contents  (directory-list home-directory))
(define nicethings-path-local (build-path home-directory nicethings-string))

;; ------------------------------------------------
;; messages
;; ------------------------------------------------
(define messages
  (hash
   'not-found                "> '~a' wasn't found."
   'not-found-prompt         "> You will need it to use nicethings.\n> Do you want to create it? [y/n]\n> "
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
                                   "> Example:"
                                   "nicethings add \"You are beautiful\".")
   'rm-expected-arg          (list "> Error: Found 'rm', but no arguments were found."
                                   "> The 'rm' command expects one number as an argument after it."
                                   "> Example:"
                                   "nicethings rm 2"
                                   "> Note: You may need to use the 'ls' command to see which number correlates to which message.")
   'ls-expected-no-args      (list "> Error: Found 'ls', but also found other arguments."
                                   "> The 'ls' command expects no arguments after it."
                                   "> Example:"
                                   "nicethings ls")
   ;; I don't currently use this message yet:
   'rm-expected-number       (list "> Error: Found '~a' after 'rm'."
                                   "> The 'rm' command expects one number as an argument after it."
                                   "> Example:"
                                   "nicethings rm 2"
                                   "> Note: You may need to use the 'ls' command to see which number correlates to which message.")
   'added                    "> Added '~a' to the list."))

;; ------------------------------------------------
;; helpers
;; ------------------------------------------------
(define (displayln-for . strings)
  (for ([string strings])
    (displayln string)))

(define-syntax-rule (displayln-format str ...)
  (displayln (format str ...)))

(define (messages-ref key)
  (hash-ref messages key))

(define (file-has-420-permissions? file)
  (equal? 420 (file-or-directory-permissions file 'bits)))

(define (append-nicethings-file home-directory)
  (build-path home-directory nicethings-string))
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
  (file-or-directory-permissions nicethings-path-local 420)
  (displayln-format (messages-ref 'permissions-fixed) nicethings-path-local)
  (exit))

(define (repair/wrong-permissions)
  (display (messages-ref 'wrong-permissions-prompt))
  (let ([user-input (read-line)])
    (case (string->symbol user-input)
      ['y   (repair/fix-permissions)]
      ['n   (repair/cancel)]
      [else (repair/not-an-option user-input)])))

(define (repair/create-file)
  (close-output-port (open-output-file nicethings-path-local))
  (displayln-format (messages-ref 'file-created) nicethings-path-local)
  (exit))

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
    [(directory-exists? nicethings-path-local)
     (begin (displayln-format (messages-ref 'fake-file-found) nicethings-path-local)
            (exit))]
    ;; Check for a missing '.nicethings' file
    [(not (file-exists? nicethings-path-local))
     (begin (displayln-format (messages-ref 'not-found) nicethings-path-local)
            (repair/not-found))]
    ;; Check for incorrect permissions on '.nicethings' file
    [(not (file-has-420-permissions? nicethings-path-local))
     (begin (displayln-format (messages-ref 'wrong-permissions) nicethings-path-local)
            (repair/wrong-permissions))]
    [else 'do-nothing]))

;; ------------------------------------------------
;; add message
;; ------------------------------------------------
;; The string-cleaned and -remade is incase there
;; are multiple newline characters. This ensures
;; there is only one newline character.
(define (add string)
  (repair)
  (let* ([string-no-newline (string-replace string "\n" "")]
         [string-newline  (string-append string-no-newline "\n")])
    ;; tell user item was added
    (display-to-file string-newline
                     nicethings-path-local
                     #:exists 'append)
    (displayln-format (messages-ref 'added) string-no-newline)))

;; ------------------------------------------------
;; random message
;; ------------------------------------------------
(define (random-message)
  (repair)
  (let* ([root                        (find-system-path 'sys-dir)]               ;; /
         [root-home                   (build-path root "home")]                  ;; /home
         [listof-homes                (directory-list root-home #:build? #t)]    ;; #:build #t builds the full path
         [paths-to-nicethings         (map append-nicethings-file listof-homes)] ;; '("/home/username/.nicethings")
         [directories-with-nicethings (filter file-exists? paths-to-nicethings)]
         [directories-with-420        (filter file-has-420-permissions? directories-with-nicethings)])
    (for ([i directories-with-420])
      (displayln i))
    ))

    ;; (when (not (zero? list-length))
    ;;   (let* ([random-number     (random list-length)]
    ;;          [random-nicething  (list-ref listof-nicethings random-number)])
    ;;     (displayln random-nicething)))))

;; ------------------------------------------------
;; help
;; ------------------------------------------------
(define (help)
  (displayln-for
   "Usage:"
   "  town nicethings [<command>] [<args>]"
   ""
   "Commands:"
   "  No command - Print a random nice thing."
   "  add        - Add a message to the list of nice things."
   "  ls         - Print a numbered list of the nice things you have added."
   "  rm         - Remove a message you have added from the list of nice things."
   ""
   "Examples:"
   "  town nicethings"
   "  town add \"You are beautiful\""
   "  town ls"
   "  town rm 2"))

(define (process-args vectorof-args)
  (define (args-ref number)
    (vector-ref vectorof-args number))
  (define (display-message key)
    (apply displayln-for (messages-ref key)))
  (match vectorof-args
    ;; Proper usage
    [(or '#("-h")
         '#("--help")
         '#("help"))  (help)]
    [(vector "add" _) (add (args-ref 1))]
    [(vector "rm" _)  (displayln "todo: make rm procedure")]
    [(vector "ls")    (displayln "todo: make ls procedure")]
    [(vector)         (random-message)]
    ;; Improper usage (Give the user hints if part of the usage is correct)
    [(vector "ls" _)  (display-message 'ls-expected-no-args)]
    [(vector "add")   (display-message 'add-expected-arg)]
    [(vector "rm")    (display-message 'rm-expected-arg)]
    [(vector _ ...)   (display-message 'try)]))

(define (main vectorof-args)
  (process-args vectorof-args))

(main (current-command-line-arguments))

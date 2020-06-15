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
  'not-found           "> '~a' wasn't found."
  'repair-prompt       "> You will need it to use nicethings.\n> Do you want to create it? [y/n]\n> "
  'fake-file-found     "> The directory '~a' was found.\n> Please move this file somewhere else before using nicethings."
  'try                 (list "> For usage help, try running the following command:"
                             "nicethings --help")
  'cancel-creation     "> Cancelled nicethings file creation."
  'file-created        "> '~a' was successfully created."
  'not-an-option       "> Error: '~a' is not an option."
  'add-expected-arg    (list "> Error: Found 'add', but no arguments were found."
                             "> The 'add' command expects one quoted argument after it."
                             "> Example:"
                             "nicethings add \"You are beautiful\".")
  'rm-expected-arg     (list "> Error: Found 'rm', but no arguments were found."
                             "> The 'rm' command expects one number as an argument after it."
                             "> Example:"
                             "nicethings rm 2"
                             "> Note: You may need to use the 'ls' command to see which number correlates to which message.")
  'ls-expected-no-args (list "> Error: Found 'ls', but also found other arguments."
                             "> The 'ls' command expects no arguments after it."
                             "> Example:"
                             "nicethings ls")
  ;; I don't currently use this message yet:
  'rm-expected-number  (list "> Error: Found '~a' after 'rm'."
                             "> The 'rm' command expects one number as an argument after it."
                             "> Example:"
                             "nicethings rm 2"
                             "> Note: You may need to use the 'ls' command to see which number correlates to which message.")
  'added               "> Added '~a' to the list."))

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
;; ------------------------------------------------
;; repair
;; ------------------------------------------------
(define (repair/not-an-option user-input)
  (displayln-format (messages-ref 'not-an-option) user-input)
  (exit))

(define (repair/cancel)
  (displayln (messages-ref 'cancel-creation))
  (exit))

;; Check for a "fake" '.nicethings' file,
;; which is a directory named '.nicethings'
(define (repair/start)
  (if (directory-exists? nicethings-path-local)
      (begin (displayln-format (messages-ref 'fake-file-found) nicethings-path-local)
             (exit))
      (begin (close-output-port (open-output-file nicethings-path-local))
             (displayln-format (messages-ref 'file-created) nicethings-path-local))))

(define (repair/prompt)
  (display (messages-ref 'repair-prompt))
  (let ([user-input (read-line)])
    (case (string->symbol user-input)
      ['y   (repair/start)]
      ['n   (repair/cancel)]
      [else (repair/not-an-option user-input)])))

(define (repair)
  (when (not (file-exists? nicethings-path-local))
    (displayln-format (messages-ref 'not-found) nicethings-path-local)
    (repair/prompt)))

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
;; The +1 includes the last element in the list
(define (random-message)
  (repair)
  ;; TODO: Don't use local path here. turn into global
  ;; Algo:
  ;; gather all directories in /home/                -> list
  ;; filter file-exists? /home/directory/.nicethings -> list
  ;; NOTES:
  ;; /home
  ;;(define root-home (build-path (find-system-path 'sys-dir) "home"))
  ;; '(/home/username _ ...)
  ;;(map path->complete-path (directory-list root-home))
  ;;;;;;;;;;;;;;
  ;; NOTES2:
  ;;(define root-home (build-path (find-system-path 'sys-dir) "home"))
  ;;(map (lambda (x) (build-path root-home x)) (directory-list root-home))
  ;;;;;;;;;;;;

  (let* ([root-home               (build-path (find-system-path 'sys-dir) "home")]
         [paths-to-nicethings     (map (lambda (home-directory) (build-path root-home home-directory nicethings-string))
                                       (directory-list root-home))])
         (filter (lambda (x) (file-exists? x)) paths-to-nicethings)))
         ;; [listof-paths    (map (lambda (path) (filter file-exists? path)) paths-to-nicethings)])

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

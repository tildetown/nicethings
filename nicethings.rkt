#lang racket

;; ------------------------------------------------
;; messages
;; ------------------------------------------------
(define messages
  (hash
  'not-found       "'~a' wasn't found."
  'repair-prompt   "You will need it to use nicethings.\nDo you want to create it? [y/n]\n> "
  'fake-file-found "The directory '~a' was found.\nPlease move this file somewhere else before using nicethings."
  'not-a-command   "Error: '~a' is not a command."
  'cancel-creation "Cancelled nicethings file creation."
  'file-created    "'~a' was successfully created."
  'not-an-option   "Error: '~a' is not an option."))

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
(define (repair/cancel)
  (displayln (messages-ref 'cancel-creation))
  (exit))

;; Check for a "fake" '.nicethings' file,
;; which is a directory named '.nicethings'
(define (repair/start dot-nicethings-path)
  (if (directory-exists? dot-nicethings-path)
      (displayln-format (messages-ref 'fake-file-found) dot-nicethings-path)
      (begin (close-output-port (open-output-file dot-nicethings-path))
             (displayln-format (messages-ref 'file-created) dot-nicethings-path))))

(define (repair/prompt dot-nicethings-path)
  (display (messages-ref 'repair-prompt))
  (let ([user-input (read-line)])
    (case (string->symbol user-input)
      ['y (repair/start dot-nicethings-path)]
      ['n (repair/cancel)]
      [else (displayln-format (messages-ref 'not-an-option) user-input)])))

(define (repair)
  (let* ([dot-nicethings-string    ".nicethings"]
         [home-directory           (find-system-path 'home-dir)]
         [listof-home-contents     (directory-list home-directory)]
         [dot-nicethings-path      (build-path home-directory dot-nicethings-string)])
    (when (not (file-exists? dot-nicethings-path))
      (displayln-format (messages-ref 'not-found) dot-nicethings-path)
      (repair/prompt dot-nicethings-path))))

;; ------------------------------------------------
;; random message
;; ------------------------------------------------
(define (random)
  ;; (let* ([home                 (get-environment-variable "HOME")]
  ;;        [listof-home-contents (directory home #t)])
  (repair))
;; ------------------------------------------------
;; help
;; ------------------------------------------------
(define (help)
  (displayln-for
   "Usage:"
   "  town nicethings [<command>] [<args>]"
   ""
   "Commands:"
   "  No command - Print a random message."
   "  add        - Add a message to the list of messages."
   "  ls         - Print a numbered list of the messages you have added."
   "  rm         - Remove a message from the list of messages."
   ""
   "Examples:"
   "  town nicethings"
   "  town add \"You are beautiful\""
   "  town ls"
   "  town rm 2"))

(define (process-args vectorof-args)
  (match vectorof-args
    [(or (vector "-h")
         (vector "--help")
         (vector "help"))  (help)]
    [(vector "add" _)      (displayln "todo: make add procedure")]
    [(vector "ls")         (displayln "todo: make ls procedure")]
    [(vector "rm" _)       (displayln "todo: make rm procedure")]
    [(vector _)            (displayln-format (messages-ref 'not-a-command) (vector-ref vectorof-args 0))]
    [_                     (random)]))

(define (main vectorof-args)
  (process-args vectorof-args))

(main (current-command-line-arguments))

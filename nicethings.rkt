#lang racket

;; ------------------------------------------------
;; messages
;; ------------------------------------------------
(define messages
  (hash
  'not-found       "'~a' wasn't found"
  'repair-prompt   "You will need it to use nicethings\nDo you want to create it? [y/n]"
  'fake-file-found "The file '~a' was found. Please move this file somewhere else to use nicethings"
  'not-a-command   "Error: '~a' is not a command"))

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
(define (repair)
  (let* ([dot-nicethings-string    ".nicethings"]
         [home-directory           (find-system-path 'home-dir)]
         [listof-home-contents     (directory-list home-directory)]
         [dot-nicethings-path      (build-path home-directory dot-nicethings-string)])
    (when (not (directory-exists? dot-nicethings-path))
      (displayln-format (messages-ref 'not-found) dot-nicethings-path)
      (displayln        (messages-ref 'repair-prompt))
      ;; Check for a "fake" '.nicethings' directory,
      ;; which is a file named '.nicethings'
      (if (file-exists? dot-nicethings-path)
          (displayln-format (messages-ref 'fake-file-found) dot-nicethings-path)
          (make-directory dot-nicethings-path))
      ;; TODO: check if file exists. basically the opposite of above
      ;;       and then create the file
      )))

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
   "  No command - Print a random message"
   "  add        - Add a message to the list of messages"
   "  ls         - Print a numbered list of the messages you have added"
   "  rm         - Remove a message from the list of messages"
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

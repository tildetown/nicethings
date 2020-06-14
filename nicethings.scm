(import scheme
        (chicken process-context)
        (chicken pathname) ;; might not need this
        (chicken format)
        (chicken file))

;; ------------------------------------------------
;; messages
;; ------------------------------------------------
(define messages
  '([not-found       . "'~a' wasn't found"]
    [repair-prompt   . "You will need it to use nicethings\nDo you want to create it? [y/n]"]
    [fake-file-found . "The file '~a' was found. Please move this file somewhere else to use nicethings"]))

;; ------------------------------------------------
;; helpers
;; ------------------------------------------------
(define (displayln string)
  (display
   (string-append string "\n")))

(define (displayln-for . strings)
  (for-each (lambda (string) (displayln string))
            strings))

(define-syntax displayln-format
  (syntax-rules ()
    ((_ str ...)
     (displayln (format str ...)))))

(define (ref alist key)
  (cdr (assq key alist)))

(define (messages-ref key)
  (ref messages key))
;; ------------------------------------------------
;; repair
;; ------------------------------------------------
(define (repair)
  (let* ([dot-nicethings           ".nicethings"]
         [home                     (get-environment-variable "HOME")]
         [listof-home-contents     (directory home #t)]
         [dot-nicethings-directory (make-pathname (list home dot-nicethings) #f)]
         [dot-nicethings-file      (make-pathname home dot-nicethings)])
    (when (not (directory-exists? dot-nicethings-directory))
      (displayln-format (messages-ref 'not-found) dot-nicethings-directory)
      (displayln        (messages-ref 'repair-prompt))
      ;; Check for a "fake" '.nicethings' directory,
      ;; which is a file named '.nicethings'
      (if (file-exists? dot-nicethings-file)
          (displayln-format (messages-ref 'fake-file-found) dot-nicethings-file)
          (create-directory dot-nicethings-directory)))))

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
   "  No command - Print a random nice thing"
   "  add        - Add a nice thing to the list of messages"
   "  ls         - Print a numbered list of the messages you have added"
   "  rm         - Remove a nice thing from the list of messages"
   ""
   "Examples:"
   "  town nicethings"
   "  town add \"You are beautiful\""
   "  town ls"
   "  town rm 2"))

(define (process-args listof-args)
  (let ([numberof-args (length listof-args)])
    (cond
     ;; no arguments
     [(= numberof-args 0) (random)]

     ;; help
     [(and (= numberof-args 1)
           (member (list-ref listof-args 0) '("-h" "--help" "help")))
      (help)]

     ;; add
     [(and (= numberof-args 2)
           (equal? (list-ref listof-args 0) "add"))
      (displayln "add procedure")]
     ;; ls
     [(and (= numberof-args 2)
           (equal? (list-ref listof-args 0) "ls"))
      (displayln "ls procedure")]

     ;; remove
     [(and (= numberof-args 2)
           (equal? (list-ref listof-args 0) "rm"))
      (displayln "rm procedure")]

     ;; else
     [else (display "didnt find\n")])))

(define (main listof-args)
  (process-args listof-args))

(main (command-line-arguments))

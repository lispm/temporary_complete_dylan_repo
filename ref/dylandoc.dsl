<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!--
    DylanDoc DSSSL Stylesheet - format DylanDoc documents for web or print
    Copyright (C) 1998 Eric Kidd

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    ****

    This stylesheet was written to work with DylanDoc 3.0, DocBook 3.0,
    and Norman Walsh's modular stylesheets, version 1.13. Other versions
    of each of these components may work.

    Autoswitch magic allows this stylesheet to support both print
    and HTML modes. Note that you might need to edit the CATALOG file
    to define the appropriate pubids for your platform.

    If you want to borrow portions of this code for non-GPL'd DSSSL
    stylesheets, I'll almost certainly grant permission. Just ask.

    Eric Kidd
    eric.kidd@pobox.com
-->

<!ENTITY % html "IGNORE">
<![%html;[
<!ENTITY % print "IGNORE">
<!ENTITY docbook.dsl SYSTEM "nwalsh-modular/html/docbook.dsl" CDATA dsssl>
]]>
<!ENTITY % print "INCLUDE">
<![%print;[
<!ENTITY docbook.dsl SYSTEM "nwalsh-modular/print/docbook.dsl" CDATA dsssl>
]]>
]>
<style-sheet>
<style-specification id="print" use="docbook">
<style-specification-body> 

;; customize the print stylesheet

</style-specification-body>
</style-specification>
<style-specification id="html" use="docbook">
<style-specification-body> 

;;;;=======================================================================
;;;; HTML Stylesheet
;;;;=======================================================================
;;;; This stylesheet uses James Clark's extensions for creating HTML from
;;;; a DSSSL stylesheet.

(define %html-ext%
  ;; We hate 8.3. Sorry.
  ".html")

(define %use-id-as-filename%
  ;; Make ID attributes into file names.
  #t)

(define (have-children? #!optional (node (current-node)))
  (not (node-list-empty? (children node))))


;;;========================================================================
;;; Inline Elements
;;;========================================================================
;;; Provide formatting for our various inline elements.

(define (process-dylan-literal #!optional (children (process-children)))
  (make element
    gi: "CODE"
    children))

(element DLibrary
  (process-dylan-literal))

(element DModule
  (process-dylan-literal))

(element DName
  (process-dylan-literal))

(element DLit
  (process-dylan-literal))


;;;========================================================================
;;; Generic Definition Support
;;;========================================================================
;;; This code implements the "look" shared by all defintions.

(define (process-def)
  (make sequence
    (process-defhead)
    (process-children)))

(define (process-defhead)
  (with-mode defhead
    (make sequence
      (make element
	gi: "TABLE"
	attributes: '(("WIDTH" "100%")
		      ("CELLPADDING" "0")
		      ("BORDER" "0"))
	(make element
	  gi: "TR"
	  (make sequence
	    (make element
	      gi: "TD"
	      (process-first-descendant "DefName"))
	    (make element
	      gi: "TD"
	      attributes: '(("ALIGN" "RIGHT"))
	      (make element
		gi: "STRONG"
		(make sequence
		  (literal "[")
		  (process-first-descendant "DefAdjectives")
		  (literal (attribute-string "DylanDefName"))
		  (literal "]")))))))
      (make element
	gi: "HR"
	(empty-sosofo))
      (process-first-descendant "DefSummary"))))

(mode defhead
  (element DefName
    (make element
      gi: "CODE"
      (make element
	gi: "B")))
  (element DefAdjectives
    (make sequence
      (process-children)
      (literal " ")))
  (element DefSummary
    (make element
      gi: "BLOCKQUOTE")))

(element DefName
  (empty-sosofo))
(element DefAdjectives
  (empty-sosofo))
(element DefSummary
  (empty-sosofo))

(define (have-child? type #!optional (node (current-node)))
  (not (node-list-empty? (select-elements (children node) (normalize type)))))

(define (section-heading name)
  (make element
    gi: "P"
    (make element
      gi: "STRONG"
      (literal name))))

(define (process-children-or-none)
  (if (have-children?)
      (process-children)
      (literal "None.")))

(define (process-section name #!optional (sect (process-children-or-none)))
  (make sequence
    (section-heading name)
    (make element
      gi: "BLOCKQUOTE"
      sect)))

(element DefDescription
  (process-section "Description"))
  

;;;========================================================================
;;; Parameter lists
;;;========================================================================
;;; Parameter list processing shared between a number of different defining
;;; forms. Parts of this are often overridden.

(define (process-parameter-section name)
  (process-section name
		   (if (have-children?)
		       (make element
			 gi: "TABLE"
			 attributes: '(("BORDER" "0")
				       ("COLUMNSPACING" "0")))
		       (literal "None."))))

(define (process-param)
  (make element
    gi: "TR"
    (make sequence
      (make element
	gi: "TD"
	attributes: '(("VALIGN" "TOP"))
	(process-first-descendant "ParamName"))
      (make element
	gi: "TD"
	(make sequence
	  (literal "An instance of ")
	  (if (have-child? "ParamType")
	      (process-first-descendant "ParamType")
	      (make element
		gi: "CODE"
		(literal "object")))
	  (literal ". ")
	  (if (have-child? "ParamSummary")
	      (process-first-descendant "ParamSummary")
	      (empty-sosofo))
	  (if (have-child? "ParamDefault")
	      (make sequence
		(literal " Defaults to ")
		(process-first-descendant "ParamDefault")
		(literal "."))
	      (empty-sosofo)))))))

(element Param
  (process-param))

(element KeyParam
  (process-param))

(element ParamName
  (make element
    gi: "EM"))

(element ParamType
  (process-dylan-literal))

(element ParamDefault
  (process-dylan-literal))

(element ParamSummary
  (process-children))


;;;========================================================================
;;; Define Class
;;;========================================================================
;;; Everything needed to define a class in the standard DRM style.

(element DylanClassDef
  (process-def))

(element DefSupers
  (process-section "Superclasses"))

(element DefSuper
  (make sequence
    (process-dylan-literal)
    (literal " ")))

(element DefInitKeywords
  (with-mode init-keywords
    (process-parameter-section "Initialization Keywords")))

(mode init-keywords
  (element ParamName
    (process-dylan-literal (make sequence
			     (process-children)
			     (literal ":")))))


;;;========================================================================
;;; Cruft
;;;========================================================================
;;; To be organized and rewritten...

(element DefType
  (make element
    gi: "CODE"
    (make sequence
      (literal " :: ")
      (process-children))))

(element DefValue
  (make element
    gi: "CODE"
    (make sequence
      (literal " = ")
      (process-children))))

(define (process-param-list)
  (if (have-children?)
       (process-children)
       (literal "()")))

(define (insert-spacer-unless-last #!optional (node (current-node)))
;;  (if (not (last-sibling? node))
;;      (literal " ")
;;      (empty-sosofo)))
;; XXX - last-sibling? ignores siblings of other types. For now, hack:
  (literal " "))

(define (parameter-keyword name)
  (make element
    gi: "B"
    (literal name)))

(mode unused
  (element DefParameters
    (make sequence
      (make element
	gi: "CODE"
	(literal " "))
      (process-param-list)))
  
  (element DefReturns
    (make sequence
    (make element
      gi: "CODE"
      (literal " => "))
    (process-param-list)))
  
  (element DefParam
    (process-children))
  
  (element ParamName
    (make sequence
      (make element
	gi: "I")
      (insert-spacer-unless-last (parent (current-node)))))
  
  (element ParamType
    (empty-sosofo))

  (element ParamSummary
    (empty-sosofo))
  
  (element RestType
    (empty-sosofo))
  
  (element Rest
    (make sequence
      (parameter-keyword "#rest")
      (literal " ")
      (process-children)))
  
  (element Key
    (make sequence
      (parameter-keyword "#key")
      (if (have-children?)
	  (literal " ")
	  (empty-sosofo))
      (process-children)
      (insert-spacer-unless-last)))
  
  (element AllKeys
    (parameter-keyword "#all-keys")))
  
(define (parameters-longform label)
  (if (have-children?)
      (make element
	gi: "BLOCKQUOTE" 
	(make sequence
	  (make element
	    gi: "P"
	    (make element
	      gi: "STRONG"
	      (literal label)))
	  (make element
	    gi: "TABLE"
	    attributes: '(("BORDER" "0")
			  ("CELLSPACING" "10"))
	    (process-children))))
      (empty-sosofo)))

(mode paramdesc
  (element ParamName
    (empty-sosofo))
  (element ParamType
    (make sequence
      (literal "An instance of type ")
      (make element
	gi: "CODE")
      (literal ". ")))
  (element RestType
    (make sequence
      (literal "Instances of type ")
      (make element
	gi: "CODE")
      (literal ". ")))
  (element ParamSingleton
    (make sequence
      (literal "The object ")
      (make element
	gi: "CODE")
      (literal ". ")))
  (element ParamSummary
    (process-children)))

(define (describe-param)
  (make element
    gi: "TR"
    (make sequence
      (make element
	gi: "TD"
	(process-first-descendant "ParamName"))
      (make element
	gi: "TD"
	(with-mode paramdesc
	  (process-children))))))

(mode parameter-summary
  (element DefParameters
    (parameters-longform "Parameters"))
  (element DefReturns
    (parameters-longform "Return Values"))
  (element DefParam
    (describe-param))
  (element Rest
    (if (have-children?)
	(describe-param)
	(empty-sosofo)))
  (element Key
    (process-children))
  (element AllKeys
    (empty-sosofo))
  (element ParamName
    (make element
      gi: "I")))

;;; Defining Constatants

(element DylanConstantDef
  (process-def))

(element DylanVariableDef
  (process-def))

(element DylanFunctionDef
  (make sequence
    (process-defhead)
    (with-mode parameter-summary
      (make sequence
	(process-first-descendant "DefParameters")
	(process-first-descendant "DefReturns")))
    (process-first-descendant "DefDescription")))


</style-specification-body>
</style-specification>
<external-specification id="docbook" document="docbook.dsl">
</style-sheet>

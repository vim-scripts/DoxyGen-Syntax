" DoxyGen syntax hilighting extension for c/c++/idl/java
" Language:     doxygen on top of c, cpp, idl, java
" Maintainer:   Michael Geddes <michaelrgeddes@optushome.com.au>
" Author:       Michael Geddes
" Last Change:  August 2004
" Version:      1.4

" NOTE:  Comments welcome!
"
" There are two variables that control the syntax hilighting produced by this
" script:
" doxygen_enhanced_colour  - Use the (non-standard) original colours designed for this hilighting.
" doxygen_my_rendering     - Disable the HTML bold/italic/underline rendering.
"
" A brief description without '.' or '!' will cause the end comment
" character to be marked as an error.  You can define the colour of this using
" the highlight doxygenErrorComment.
"
" Usage:
"
" Installation Instructions
"
" 1. Create the directory ~/.vim/syntax and move doxygen.vim into it:
"
" cd
" mkdir -p .vim/syntax
" mv doxygen.vim .vim/syntax
"
" Some flavours of UNIX do not support mkdir -p.  In that case, just create the
" directories individually:
"
" mkdir .vim .vim/syntax
"
" 2. Add the following to your ~/.vimrc file to cause vim to use doxygen.vim
" syntax highlighting whenever editing pure Doxygen files.
"
" au BufNewFile,BufRead *.doxygen setfiletype doxygen
"
" Now vim will use the doxygen.vim syntax highlighting whenever editing files
" named *.doxygen.  If you use a different name for your pure Doxygen files,
" replace "*.doxygen" in the above line with the file name you use, such
" as "*.dox".
"
" 3. For programming language source files, doxygen.vim must be loaded last.
" Vim loads the scripts in the ~/.vim/after/syntax directory after it loads
" the normal language syntax.  Create the directory and make links to
" doxygen.vim:
"
" mkdir -p .vim/after/syntax
" cd .vim/after/syntax
" ln -s ../../syntax/doxygen.vim c.vim      (for C)
" ln -s ../../syntax/doxygen.vim cpp.vim    (for C++)
"
" And so on for each language for which you will use Doxygen.
" If you can't use ln, then create files c.vim, cpp.vim that source
" ../../syntax/doxygen.vim
"
" Alternatively, either:
" 1: create files .vim/syntax/c.vim  .vim/syntax/cpp.vim .vim/syntax/ which 
"   load the original syntax before loading doxygen.vim syntax hilighting. 
" or
" 2: Before :syntax on in your _vimrc, put 
" let mysyntaxfile='<some_path>/doxygen_load.vim 
" and then create the following file. 
" -----------8<--------- <some_path>/doxygen_load.vim -------- 
" au! Syntax {cpp,c,idl} 
" au Syntax {cpp,c,idl} runtime syntax/doxygen.vim 
" ------------------------------------------------------------ 

"
" History:
" 1.1:
"   - Added support for @brief lines at the start, rather than automatic
"       brief (Suggested by Peter Wright)
"   - As an extension support brief comment on a single line followed by
"   multiline doxygen comment.
" 1.2
"   - Add a hilight group for @bug, default to TODO hilighting.(suggested by
"       Markus Trenkwalder)
"   - Fix brief comment on a single line being overzealous - (reported by Markus Trenkwalder)
" 1.3
"   - HTML Hilighting support fixed (reported by Brett Humphreys)
"   - HTML hilighting extended to support bold/italic/underline (coppied from
"       html.vim).
"   - Support a few more recent additions to doxygen.
"   - Support standard colour sets - use doxygen_enhanced_colour to use old
"       sets.
" 1.4
"   - Patches from Wu Yongwei
"     * Include '-' in inline \c \e maching.
"     * \see, \return are multiline desc.
"     * \throw can now handle std::alloc (colons were confusing it)
"   - Fixed support for <a href=> links.
"   - Reported by Wu Yongwei
"     * Handle [in,out] in \param.
"     * Handle non-terminating . in a brief description (eg A.B)
"     * allow leading asterix inside HTML marks.
"     * Fix up <a> link hilighting when interupted by new-lines and comment
"     continuations.
"     * Handle the case where \c \ref etc are used at the beginning of a 'brief'
"     line.
"   - Fixed termination of multiline at start of new command.
"   - Include John McGehee's instructions.
"
if exists('b:current_syntax') && b:current_syntax =~ 'doxygen' && !exists('doxygen_debug_script')
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" Start of Doxygen syntax hilighting:
"

" C/C++ Style line comments
"syn region doxygenComment start=+/\*[*!]+  end=+\*/+ contains=doxygenStart,doxygenTODO keepend
syn region doxygenComment start=+/\*[*!]+  		end=+\*/+ contains=doxygenSyncStart,doxygenStart,doxygenTODO keepend
syn region doxygenCommentL start=+//[/!]+me=e-1 end=+$+ contains=doxygenStartL keepend skipwhite skipnl nextgroup=doxygenComment2
syn region doxygenCommentL start=+//@[{}]+ end=+$+

" Single line brief followed by multiline comment.
syn region doxygenComment2 start=+/\*[*!]+ end=+\*/+ contained contains=doxygenSyncStart2,doxygenStart2,doxygenTODO keepend
" This helps with sync-ing as for some reason, syncing behaves differently to a normal region, and the start pattern does not get matched.
syn match doxygenSyncStart2 +[^*/]+ contained nextgroup=doxygenBody,doxygenPrev,doxygenStartSpecial,doxygenSkipComment,doxygenStartSkip2 skipwhite skipnl

" Skip empty lines at the start for when comments start on the 2nd/3rd line.
syn match doxygenStartSkip2 +^\s*\*[^/]+me=e-1 contained nextgroup=doxygenBody,doxygenStartSpecial,doxygenStartSkip skipwhite skipnl
syn match doxygenStartSkip2 +^\s*\*$+ contained nextgroup=doxygenBody,doxygenStartSpecial,,doxygenStartSkip skipwhite skipnl
syn match doxygenStart2 +/\*[*!]+ contained nextgroup=doxygenBody,doxygenPrev,doxygenStartSpecial,doxygenStartSkip2 skipwhite skipnl

" Match the Starting pattern (effectively creating the start of a BNF)
syn match doxygenStart +/\*[*!]+ contained nextgroup=doxygenBrief,doxygenPrev,doxygenFindBriefSpecial,doxygenStartSpecial,doxygenStartSkip,doxygenPage skipwhite skipnl
syn match doxygenStartL +//[/!]+ contained nextgroup=doxygenPrevL,doxygenBriefL,doxygenSpecial skipwhite

" This helps with sync-ing as for some reason, syncing behaves differently to a normal region, and the start pattern does not get matched.
syn match doxygenSyncStart +[^*/]+ contained nextgroup=doxygenBrief,doxygenPrev,doxygenStartSpecial,doxygenFindBriefSpecial,doxygenStartSkip,doxygenPage skipwhite skipnl

" Match the first sentence as a brief comment
syn region doxygenBrief contained start=+\\\([pcbea]\|em\|ref\)\>+ start=+\<\k+ skip=+[.!]\S+ end=+[.!]+ contains=doxygenSmallSpecial,doxygenContinueComment,doxygenErrorComment,doxygenFindBriefSpecial,doxygenSmallSpecial,@doxygenHtmlGroup,doxygenTODO,doxygenOtherLink skipnl nextgroup=doxygenBody

syn region doxygenBriefL start=+@\k\@!\|\\\([pcbea]\|em\|ref\)\>+ start=+\<+ skip=+[.!]\S+ end=+[.!]\|$+ contained contains=doxygenSmallSpecial,@doxygenHtmlGroup keepend

syn region doxygenBriefLine contained start=+\<\k+ skip=+^\s*\(\*[^/]\)\=\s*\([@\\]ar[^g]\|[^ \t\*]\)+ end=+^+ contains=doxygenContinueComment,doxygenErrorComment,doxygenFindBriefSpecial,doxygenSmallSpecial,@doxygenHtmlGroup,doxygenTODO,doxygenOtherLink skipwhite keepend

" Match a '<' for applying a comment to the previous element.
syn match doxygenPrev +<+ contained nextgroup=doxygenBrief,doxygenSpecial,doxygenStartSkip skipwhite
syn match doxygenPrevL +<+ contained  nextgroup=doxygenBriefL,doxygenSpecial skipwhite

" These are anti-doxygen comments.  If there are more than two asterixes or 3 '/'s
" then turn the comments back into normal C comments.
syn region cComment start="/\*\*\*" end="\*/" contains=@cCommentGroup,cCommentString,cCharacter,cNumbersCom,cSpaceError
syn region cCommentL start="////" skip="\\$" end="$" contains=@cCommentGroup,cComment2String,cCharacter,cNumbersCom,cSpaceError

" Special commands at the start of the area:  starting with '@' or '\'
syn region doxygenStartSpecial contained start=+@\<\|\\\([pcbea]\|em\|ref\)\@!+ end=+$+ end=+\*/+me=s-1,he=s-1  contains=doxygenSpecial nextgroup=doxygenSkipComment skipnl keepend
syn match doxygenSkipComment contained +^\s*\*[^/]+me=e-1 nextgroup=doxygenBrief,doxygenStartSpecial,doxygenFindBriefSpecial,doxygenPage skipwhite

"syn region doxygenBodyBit contained start=+$+

" The main body of a doxygen comment.
syn region doxygenBody contained start=+.\|$+ matchgroup=doxygenEndComment end=+\*/+re=e-2,me=e-2 contains=doxygenContinueComment,doxygenTODO,doxygenSpecial,@doxygenHtmlGroup

" These allow the skipping of comment continuation '*' characters.
syn match doxygenContinueComment contained +^\s*\*/\@!\s*+

"syn match doxygenErrorEnd contained +/+

" Catch a Brief comment without punctuation - flag it as an error but
" make sure the end comment is picked up also.
syn match doxygenErrorComment contained +\*/+


" Skip empty lines at the start for when comments start on the 2nd/3rd line.
syn match doxygenStartSkip +^\s*\*[^/]+me=e-1 contained nextgroup=doxygenBrief,doxygenStartSpecial,doxygenFindBriefSpecial,doxygenStartSkip,doxygenPage skipwhite skipnl
syn match doxygenStartSkip +^\s*\*$+ contained nextgroup=doxygenBrief,doxygenStartSpecial,doxygenFindBriefSpecial,doxygenStartSkip,doxygenPage skipwhite skipnl

" Match an [@\]brief so that it moves to body-mode.
"
"
" syn match doxygenBriefLine  contained
syn match doxygenBriefSpecial contained +[@\\]+ nextgroup=doxygenBriefWord skipwhite
syn region doxygenFindBriefSpecial start=+[@\\]brief\>+ skip=+^\s*\(\*[^/]\)\=\s*\([@\\]ar[^g]\|[^ \t\*]\)+ end=+^+ keepend contains=doxygenBriefSpecial nextgroup=doxygenBody keepend skipwhite skipnl contained

" Create the single word matching special identifiers.

fun! DxyCreateSmallSpecial( kword, name )
  exe 'syn keyword doxygenSpecial'.a:name.'Word contained '.a:kword.' nextgroup=doxygen'.a:name.'Word skipwhite'
  exe 'syn match doxygen'.a:name.'Word contained "[-a-zA-Z_:0-9]\+" '
endfun
call DxyCreateSmallSpecial('p', 'Code')
call DxyCreateSmallSpecial('c', 'Code')
call DxyCreateSmallSpecial('b', 'Bold')
call DxyCreateSmallSpecial('e', 'Emphasised')
call DxyCreateSmallSpecial('em', 'Emphasised')
call DxyCreateSmallSpecial('a', 'Argument')
call DxyCreateSmallSpecial('ref', 'Ref')
delfun DxyCreateSmallSpecial

syn match doxygenSmallSpecial contained +@\<\|\\+ nextgroup=doxygenFormula,doxygenSymbol,doxygenSpecial.*Word

" Now for special characters
syn match doxygenSpecial contained +@\<\|\\\([pcbea]\>\|em\>\|ref\>\)\@!+ nextgroup=doxygenParam,doxygenRetval,doxygenBriefWord,doxygenBold,doxygenBOther,doxygenOther,doxygenOtherTODO,doxygenOtherWARN,doxygenOtherBUG,doxygenPage,doxygenOtherLink,doxygenSymbol,doxygenFormula,doxygenErrorSpecial,doxygenSpecial.*Word
syn match doxygenErrorSpecial contained +\s+

" Match Parmaters and retvals (hilighting the first word as special).
syn match doxygenParamDirection contained +\[\(\<in\>\|\<out\>\|,\)\+\]+ nextgroup=doxygenParamName skipwhite
syn keyword doxygenParam contained param nextgroup=doxygenParamName,doxygenParamDirection skipwhite
syn match doxygenParamName contained +[A-Za-z0-9_:]\++ nextgroup=doxygenSpecialMultilineDesc skipwhite
syn keyword doxygenRetval contained retval throw exception nextgroup=doxygenParamName skipwhite

" Match one line identifiers.
syn keyword doxygenOther contained addindex anchor code
\ dontinclude endcode endhtmlonly endlatexonly endverbatim showinitializer hideinitializer
\ example htmlonly image include ingroup internal latexonly line
\ overload relates relatesalso sa skip skipline
\ until verbatim verbinclude version addtogroup htmlinclude copydoc dot enddot dotfile
\ xmlonly endxmlonly
\ nextgroup=doxygenSpecialOnelineDesc

" Match multiline identifiers.
syn keyword doxygenBOther contained class enum file fn mainpage interface
\ namespace struct typedef union var def name invariant note post pre remarks
\ since test
\ nextgroup=doxygenSpecialTypeOnelineDesc

syn keyword doxygenOther contained par nextgroup=doxygenHeaderLine
syn region doxygenHeaderLine start=+.+ end=+^+ contained skipwhite nextgroup=doxygenSpecialMultilineDesc

syn keyword doxygenOther contained arg author date deprecated li return see nextgroup=doxygenSpecialMultilineDesc
syn keyword doxygenOtherTODO contained todo attention nextgroup=doxygenSpecialMultilineDesc
syn keyword doxygenOtherWARN contained warning nextgroup=doxygenSpecialMultilineDesc
syn keyword doxygenOtherBUG contained bug nextgroup=doxygenSpecialMultilineDesc

" Handle \link, \endlink, hilighting the link-to and the link text bits separately.
syn region doxygenOtherLink matchgroup=doxygenOther start=+link+ end=+[\@]endlink+ contained contains=doxygenLinkWord,doxygenContinueComment
syn match doxygenLinkWord "[_a-zA-Z:#()]\+\>" contained skipnl nextgroup=doxygenLinkRest,doxygenContinueLinkComment
syn match doxygenLinkRest +.+ contained skipnl nextgroup=doxygenLinkRest,doxygenContinueLinkComment
syn match doxygenContinueLinkComment contained +^\s*\*\=[^/]+me=e-1 nextgroup=doxygenLinkRest

" Handle \page.  This does not use doxygenBrief.
syn match doxygenPage "[\\@]page"me=s+1 contained skipwhite nextgroup=doxygenPagePage
syn keyword doxygenPagePage page contained skipwhite nextgroup=doxygenPageIdent
syn region doxygenPageDesc  start=+.\++ end=+$+ contained skipwhite contains=doxygenSmallSpecial,@doxygenHtmlGroup keepend skipwhite skipnl nextgroup=doxygenBody
syn match doxygenPageIdent "\<[a-zA-Z0-9]\+\>" contained nextgroup=doxygenPageDesc

" Handle section
syn keyword doxygenOther defgroup section subsection subsubsection weakgroup contained skipwhite nextgroup=doxygenSpecialIdent
syn region doxygenSpecialSectionDesc  start=+.\++ end=+$+ contained skipwhite contains=doxygenSmallSpecial,@doxygenHtmlGroup keepend skipwhite skipnl nextgroup=doxygenContinueComment
syn match doxygenSpecialIdent "\<[a-zA-Z0-9]\+\>" contained nextgroup=doxygenSpecialSectionDesc

" Does the one-line description for the one-line type identifiers.
syn region doxygenSpecialTypeOnelineDesc  start=+.\++ end=+$+ contained skipwhite contains=doxygenSmallSpecial,@doxygenHtmlGroup keepend
syn region doxygenSpecialOnelineDesc  start=+.\++ end=+$+ contained skipwhite contains=doxygenSmallSpecial,@doxygenHtmlGroup keepend

" Handle the multiline description for the multiline type identifiers.
syn region doxygenSpecialMultilineDesc  start=+.\++ skip=+^\s*\(\*[^/]\)\=\s*\([@\\]ar[^g]\|[^ \\@\t\*]\|\\[pcbea]\>\|\\em\>\|\\ref\>\|\\[\\<>&]\s*\<\)+ end=+^+ contained contains=doxygenSpecialContinueComment,doxygenSmallSpecial,@doxygenHtmlGroup  skipwhite keepend
syn match doxygenSpecialContinueComment contained +^\s*\*[^/]+me=e-1 nextgroup=doxygenSpecial skipwhite

" Handle special cases  'bold' and 'group'
syn keyword doxygenBold contained bold nextgroup=doxygenSpecialHeading
syn keyword doxygenBriefWord contained brief nextgroup=doxygenBriefLine skipwhite
syn match doxygenSpecialHeading +.\++ contained skipwhite
syn keyword doxygenGroup contained group nextgroup=doxygenGroupName skipwhite
syn keyword doxygenGroupName contained +\k\++ nextgroup=doxygenSpecialOnelineDesc skipwhite

" Handle special symbol identifiers  @$, @\, @$ etc
syn match doxygenSymbol contained +[$\\&<>#]+

" Simplistic handling of formula regions
syn region doxygenFormula contained matchgroup=doxygenFormulaEnds start=+f\$+ end=+[@\\]f\$+ contains=doxygenFormulaSpecial,doxygenFormulaOperator
syn match doxygenFormulaSpecial contained +[@\\]\(f[^$]\|[^f]\)+me=s+1 nextgroup=doxygenFormulaKeyword,doxygenFormulaEscaped
syn match doxygenFormulaEscaped contained "."
syn match doxygenFormulaKeyword contained  "[a-z]\+"
syn match doxygenFormulaOperator contained +[_^]+

syn region doxygenFormula contained matchgroup=doxygenFormulaEnds start=+f\[+ end=+[@\\]f]+ contains=doxygenFormulaSpecial,doxygenFormulaOperator,doxygenAtom
syn region doxygenAtom contained transparent matchgroup=doxygenFormulaOperator start=+{+ end=+}+ contains=doxygenAtom,doxygenFormulaSpecial,doxygenFormulaOperator

" Add TODO hilighting.
syn keyword doxygenTODO contained TODO README XXX FIXME

" Supported HTML subset.  Not perfect, but okay.
syn case ignore
syn region doxygenHtmlTag contained matchgroup=doxygenHtmlCh start=+</\=\ze\k\+\>+ skip=+\\<\|\<\k\+=\("[^"]*"\|'[^']*\)+ end=+>+ contains=doxygenHtmlCmd,doxygenContinueComment,doxygenHtmlVar
syn keyword doxygenHtmlCmd contained b i em strong u img a br p center code dfn dl dd dt hr h1 h2 h3 li ol ul pre small sub sup table tt var caption nextgroup=doxygenHtmlVar skipwhite
syn keyword doxygenHtmlVar contained src alt longdesc name height width usemap ismap href type nextgroup=doxygenHtmlEqu skipwhite
syn match doxygenHtmlEqu contained +=+ nextgroup=doxygenHtmlExpr skipwhite
syn match doxygenHtmlExpr contained +"\(\\.\|[^"]\)*"\|'\(\\.\|[^']\)*'+ nextgroup=doxygenHtmlVar skipwhite
syn case match
syn match doxygenHtmlSpecial contained "&\(copy\|quot\|[AEIOUYaeiouy]uml\|[AEIOUYaeiouy]acute\|[AEIOUaeiouy]grave\|[AEIOUaeiouy]circ\|[ANOano]tilde\|szlig\|[Aa]ring\|nbsp\);"

syn cluster doxygenHtmlGroup contains=doxygenHtmlCode,doxygenHtmlBold,doxygenHtmlUnderline,doxygenHtmlItalic,doxygenHtmlSpecial,doxygenHtmlTag,doxygenHtmlLink

syn cluster doxygenHtmlTop contains=@Spell,doxygenHtmlSpecial,doxygenHtmlTag,doxygenContinueComment
" Html Support
syn region doxygenHtmlLink contained start=+<[aA]\>\s*\(\n\s*\*\s*\)\=\(\(name\|href\)=\("[^"]*"\|'[^']*'\)\)\=\s*>+ end=+</[aA]>+me=e-4 contains=@doxygenHtmlTop
hi link doxygenHtmlLink Underlined

syn region doxygenHtmlBold contained start="\c<b\>" end="\c</b>"me=e-4 contains=@doxygenHtmlTop,doxygenHtmlBoldUnderline,doxygenHtmlBoldItalic
syn region doxygenHtmlBold contained start="\c<strong\>" end="\c</strong>"me=e-9 contains=@doxygenHtmlTop,doxygenHtmlBoldUnderline,doxygenHtmlBoldItalic
syn region doxygenHtmlBoldUnderline contained start="\c<u\>" end="\c</u>"me=e-4 contains=@doxygenHtmlTop,doxygenHtmlBoldUnderlineItalic
syn region doxygenHtmlBoldItalic contained start="\c<i\>" end="\c</i>"me=e-4 contains=@doxygenHtmlTop,doxygenHtmlBoldItalicUnderline
syn region doxygenHtmlBoldItalic contained start="\c<em\>" end="\c</em>"me=e-5 contains=@doxygenHtmlTop,doxygenHtmlBoldItalicUnderline
syn region doxygenHtmlBoldUnderlineItalic contained start="\c<i\>" end="\c</i>"me=e-4 contains=@doxygenHtmlTop
syn region doxygenHtmlBoldUnderlineItalic contained start="\c<em\>" end="\c</em>"me=e-5 contains=@doxygenHtmlTop
syn region doxygenHtmlBoldItalicUnderline contained start="\c<u\>" end="\c</u>"me=e-4 contains=@doxygenHtmlTop,doxygenHtmlBoldUnderlineItalic

syn region doxygenHtmlUnderline contained start="\c<u\>" end="\c</u>"me=e-4 contains=@doxygenHtmlTop,doxygenHtmlUnderlineBold,doxygenHtmlUnderlineItalic
syn region doxygenHtmlUnderlineBold contained start="\c<b\>" end="\c</b>"me=e-4 contains=@doxygenHtmlTop,doxygenHtmlUnderlineBoldItalic
syn region doxygenHtmlUnderlineBold contained start="\c<strong\>" end="\c</strong>"me=e-9 contains=@doxygenHtmlTop,doxygenHtmlUnderlineBoldItalic
syn region doxygenHtmlUnderlineItalic contained start="\c<i\>" end="\c</i>"me=e-4 contains=@doxygenHtmlTop,htmUnderlineItalicBold
syn region doxygenHtmlUnderlineItalic contained start="\c<em\>" end="\c</em>"me=e-5 contains=@doxygenHtmlTop,htmUnderlineItalicBold
syn region doxygenHtmlUnderlineItalicBold contained start="\c<b\>" end="\c</b>"me=e-4 contains=@doxygenHtmlTop
syn region doxygenHtmlUnderlineItalicBold contained start="\c<strong\>" end="\c</strong>"me=e-9 contains=@doxygenHtmlTop
syn region doxygenHtmlUnderlineBoldItalic contained start="\c<i\>" end="\c</i>"me=e-4 contains=@doxygenHtmlTop
syn region doxygenHtmlUnderlineBoldItalic contained start="\c<em\>" end="\c</em>"me=e-5 contains=@doxygenHtmlTop

syn region doxygenHtmlItalic contained start="\c<i\>" end="\c</i>"me=e-4 contains=@doxygenHtmlTop,doxygenHtmlItalicBold,doxygenHtmlItalicUnderline
syn region doxygenHtmlItalic contained start="\c<em\>" end="\c</em>"me=e-5 contains=@doxygenHtmlTop
syn region doxygenHtmlItalicBold contained start="\c<b\>" end="\c</b>"me=e-4 contains=@doxygenHtmlTop,doxygenHtmlItalicBoldUnderline
syn region doxygenHtmlItalicBold contained start="\c<strong\>" end="\c</strong>"me=e-9 contains=@doxygenHtmlTop,doxygenHtmlItalicBoldUnderline
syn region doxygenHtmlItalicBoldUnderline contained start="\c<u\>" end="\c</u>"me=e-4 contains=@doxygenHtmlTop
syn region doxygenHtmlItalicUnderline contained start="\c<u\>" end="\c</u>"me=e-4 contains=@doxygenHtmlTop,doxygenHtmlItalicUnderlineBold
syn region doxygenHtmlItalicUnderlineBold contained start="\c<b\>" end="\c</b>"me=e-4 contains=@doxygenHtmlTop
syn region doxygenHtmlItalicUnderlineBold contained start="\c<strong\>" end="\c</strong>"me=e-9 contains=@doxygenHtmlTop

syn region doxygenHtmlCode contained start="\c<code\>" end="\c</code>"me=e-7 contains=@doxygenHtmlTop

" Prevent the doxygen contained matches from leaking into the c groups.
syn cluster cParenGroup add=doxygen.*
syn cluster cPreProcGroup add=doxygen.*
syn cluster cMultiGroup add=doxygen.*
syn cluster rcParenGroup add=doxygen.*
syn cluster rcGroup add=doxygen.*

" Trick to force special doxygen hilighting if the background changes (need to
" syn clear first)
if exists("did_doxygen_syntax_inits")
  if did_doxygen_syntax_inits != &background && synIDattr(highlightID('doxygen_Dummy'), 'fg', 'gui')==''
    command -nargs=+ HiColour hi <args>
    unlet did_doxygen_syntax_inits
  endif
else
    command -nargs=+ HiColour hi def <args>
endif

if !exists("did_doxygen_syntax_inits")
  command -nargs=+ HiLink hi def link <args>
  let did_doxygen_syntax_inits = &background
  hi doxygen_Dummy guifg=black

  HiLink doxygenHtmlSpecial Special
  HiLink doxygenHtmlVar Type
  HiLink doxygenHtmlExpr String

  HiLink doxygenSmallSpecial SpecialChar

  HiLink doxygenSpecialCodeWord doxygenSmallSpecial
  HiLink doxygenSpecialEmphasisedWord doxygenSmallSpecial
  HiLink doxygenSpecialBoldWord doxygenSmallSpecial

  " HiColour doxygenFormulaKeyword cterm=bold ctermfg=DarkMagenta guifg=DarkMagenta gui=bold
  HiLink doxygenFormulaKeyword Keyword
  "HiColour doxygenFormulaEscaped  ctermfg=DarkMagenta guifg=DarkMagenta gui=bold
  HiLink doxygenFormulaEscaped Special
  HiLink doxygenFormulaOperator Operator
  HiLink doxygenFormula Statement
  HiLink doxygenSymbol Constant
  HiLink doxygenSpecial Special
  HiLink doxygenFormulaSpecial Special
  "HiColour doxygenFormulaSpecial ctermfg=DarkBlue guifg=DarkBlue

  if exists('doxygen_enhanced_color') || exists('doxygen_enhanced_colour')
    if &background=='light'
      HiColour doxygenComment ctermfg=DarkRed guifg=DarkRed
      HiColour doxygenBrief cterm=bold ctermfg=Cyan guifg=DarkBlue gui=bold
      HiColour doxygenBody ctermfg=DarkBlue guifg=DarkBlue
      HiColour doxygenSpecialTypeOnelineDesc cterm=bold ctermfg=DarkRed guifg=firebrick3 gui=bold
      HiColour doxygenBOther cterm=bold ctermfg=DarkMagenta guifg=#aa50aa gui=bold
      HiColour doxygenParam ctermfg=DarkGray guifg=#aa50aa
      HiColour doxygenParamName cterm=italic ctermfg=DarkBlue guifg=DeepSkyBlue4 gui=italic,bold
      HiColour doxygenSpecialOnelineDesc cterm=bold ctermfg=DarkCyan guifg=DodgerBlue3 gui=bold
      HiColour doxygenSpecialHeading cterm=bold ctermfg=DarkBlue guifg=DeepSkyBlue4 gui=bold
      HiColour doxygenPrev ctermfg=DarkGreen guifg=DarkGreen
    else
      HiColour doxygenComment ctermfg=LightRed guifg=LightRed
      HiColour doxygenBrief cterm=bold ctermfg=Cyan ctermbg=darkgrey guifg=Blue gui=bold
      HiColour doxygenBody ctermfg=Cyan guifg=Blue
      HiColour doxygenSpecialTypeOnelineDesc cterm=bold ctermfg=Red guifg=firebrick3 gui=bold
      HiColour doxygenBOther cterm=bold ctermfg=Magenta guifg=#aa50aa gui=bold
      HiColour doxygenParam ctermfg=LightGray guifg=LightGray
      HiColour doxygenParamName cterm=italic ctermfg=LightBlue guifg=LightBlue gui=italic,bold
      HiColour doxygenSpecialOnelineDesc cterm=bold ctermfg=LightCyan guifg=LightCyan gui=bold
      HiColour doxygenSpecialHeading cterm=bold ctermfg=LightBlue guifg=LightBlue gui=bold
      HiColour doxygenPrev ctermfg=LightGreen guifg=LightGreen
    endif
  else
    HiLink doxygenComment SpecialComment
    HiLink doxygenBrief Statement
    HiLink doxygenBody Comment
    HiLink doxygenSpecialTypeOnelineDesc Statement
    HiLink doxygenBOther Constant
    HiLink doxygenParam SpecialComment
    HiLink doxygenParamName Underlined
    HiLink doxygenSpecialOnelineDesc Statement
    HiLink doxygenSpecialHeading Statement
    HiLink doxygenPrev SpecialComment
  endif

  HiLink doxygenBody                   Comment
  HiLink doxygenTODO                   Todo
  HiLink doxygenOtherTODO              Todo
  HiLink doxygenOtherWARN              Todo
  HiLink doxygenOtherBUG               Todo

  HiLink doxygenErrorSpecial           Error
  HiLink doxygenErrorEnd               Error
  HiLink doxygenErrorComment           Error
  HiLink doxygenBriefSpecial           doxygenSpecial

  HiLink doxygenSpecialMultilineDesc   doxygenSpecialOnelineDesc
  HiLink doxygenFormulaEnds            doxygenSpecial
  HiLink doxygenBold                   doxygenParam
  HiLink doxygenBriefWord              doxygenParam
  HiLink doxygenRetval                 doxygenParam
  HiLink doxygenOther                  doxygenParam
  HiLink doxygenStart                  doxygenComment
  HiLink doxygenStart2                 doxygenStart
  HiLink doxygenComment2               doxygenComment
  HiLink doxygenCommentL               doxygenComment
  HiLink doxygenContinueComment        doxygenComment
  HiLink doxygenSpecialContinueComment doxygenComment
  HiLink doxygenSkipComment            doxygenComment
  HiLink doxygenEndComment             doxygenComment
  HiLink doxygenStartL                 doxygenComment
  HiLink doxygenPrevL                  doxygenPrev
  HiLink doxygenBriefL                 doxygenBrief
  HiLink doxygenBriefLine              doxygenBrief
  HiLink doxygenHeaderLine             doxygenSpecialHeading
  HiLink doxygenStartSkip              doxygenContinueComment
  HiLink doxygenLinkWord               doxygenParamName
  HiLink doxygenLinkRest               doxygenSpecialMultilineDesc

  HiLink doxygenPage                   doxygenSpecial
  HiLink doxygenPagePage               doxygenBOther
  HiLink doxygenPageIdent              doxygenParamName
  HiLink doxygenPageDesc               doxygenSpecialTypeOnelineDesc

  HiLink doxygenSpecialIdent           doxygenPageIdent
  HiLink doxygenSpecialSectionDesc     doxygenSpecialMultilineDesc

  HiLink doxygenSpecialRefWord         doxygenOther
  HiLink doxygenRefWord                doxygenPageIdent
  HiLink doxygenContinueLinkComment    doxygenComment

  HiLink doxygenHtmlCh                 Function
  HiLink doxygenHtmlCmd                Statement
  HiLink doxygenHtmlBoldItalicUnderline     doxygenHtmlBoldUnderlineItalic
  HiLink doxygenHtmlUnderlineBold           doxygenHtmlBoldUnderline
  HiLink doxygenHtmlUnderlineItalicBold     doxygenHtmlBoldUnderlineItalic
  HiLink doxygenHtmlUnderlineBoldItalic     doxygenHtmlBoldUnderlineItalic
  HiLink doxygenHtmlItalicUnderline         doxygenHtmlUnderlineItalic
  HiLink doxygenHtmlItalicBold              doxygenHtmlBoldItalic
  HiLink doxygenHtmlItalicBoldUnderline     doxygenHtmlBoldUnderlineItalic
  HiLink doxygenHtmlItalicUnderlineBold     doxygenHtmlBoldUnderlineItalic
  HiLink doxygenHtmlLink                    Underlined

  HiLink doxygenParamDirection              StorageClass

  if !exists("doxygen_my_rendering") && !exists("html_my_rendering")
    HiColour doxygenCodeWord             term=bold cterm=bold font=Lucida_Console:h10
    HiColour doxygenBoldWord             term=bold cterm=bold gui=bold
    HiColour doxygenEmphasisedWord       term=italic cterm=italic gui=italic
    HiLink   doxygenArgumentWord         doxygenEmphasisedWord
    HiLink   doxygenHtmlCode             doxygenCodeWord
    HiLink   doxygenHtmlBold             doxygenBoldWord
    HiColour doxygenHtmlBoldUnderline       term=bold,underline cterm=bold,underline gui=bold,underline
    HiColour doxygenHtmlBoldItalic          term=bold,italic cterm=bold,italic gui=bold,italic
    HiColour doxygenHtmlBoldUnderlineItalic term=bold,italic,underline cterm=bold,italic,underline gui=bold,italic,underline
    HiColour doxygenHtmlUnderline        term=underline cterm=underline gui=underline
    HiColour doxygenHtmlUnderlineItalic  term=italic,underline cterm=italic,underline gui=italic,underline
    HiColour doxygenHtmlItalic           term=italic cterm=italic gui=italic
  endif
  delcommand HiLink
  delcommand HiColour
endif

if &syntax=='idl'
  syn cluster idlCommentable add=doxygenComment,doxygenCommentL
endif

"syn sync clear
"syn sync maxlines=500
"syn sync minlines=50
if v:version >= 600
syn sync match doxygenComment groupthere cComment "/\@<!/\*"
syn sync match doxygenSyncComment grouphere doxygenComment "/\@<!/\*[*!]"
else
syn sync match doxygencComment groupthere cComment "/\*"
syn sync match doxygenSyncComment grouphere doxygenComment "/\*[*!]"
endif
"syn sync match doxygenSyncComment grouphere doxygenComment "/\*[*!]" contains=doxygenStart,doxygenTODO keepend
syn sync match doxygenSyncEndComment groupthere NONE "\*/"

if !exists('b:current_syntax')
  let b:current_syntax = "doxygen"
else
  let b:current_syntax = b:current_syntax.'+doxygen'
endif

let &cpo = s:cpo_save
unlet s:cpo_save


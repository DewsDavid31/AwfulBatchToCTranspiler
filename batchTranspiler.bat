@echo off
SETLOCAL EnableDelayedExpansion
set /p pat=Enter path to file needed
cd %pat%
set /p infile=Enter a batch file to painfully compile to c using batch: 
echo excruciatingly creating symbol table....
:SyntacticAnalyzer
set index=0
set percen="%"
set semIndex=0
set symbols[0]=
set values[0]=
FOR /F "tokens=1* delims= " %%a in (%infile%) DO (
       set symbol=%%a
       set value=%%b
       if /i "!symbol!"=="setlocal" echo "SCOPESETTINGS symbol: %%a"
       if /i "!symbol!"=="setlocal" set symbols[!index!]="SCOPESETTINGS"
       if /i "!symbol!"=="@echo" echo "ECHOSETTINGS symbol: %%a"
       if /i "!symbol!"=="@echo" set symbols[!index!]="ECHOSETTINGS"
       if /i "!symbol!"=="if" echo "IF symbol: %%a"
       if /i "!symbol!"=="if" set symbols[!index!]="IF"
       if /i "!symbol!"=="call" echo "MACRO symbol: %%a"
       if /i "!symbol!"=="call" set symbols[!index!]="MACRO"
       if /i "!symbol!"=="goto" echo "JUMP symbol: %%a"
       if /i "!symbol!"=="goto" set symbols[!index!]="JUMP"
       if /i "!symbol!"==")" echo "END BLOCK symbol: %%a"
       if /i "!symbol!"==")" set symbols[!index%]="END BLOCK"
       if /i "!symbol!"=="set" echo "ASSIGN symbol: %%a"
       if /i "!symbol!"=="set" set symbols[!index!]="ASSIGN"
       if /i "!symbol!"=="for" echo "FOR symbol: %%a"
       if /i "!symbol!"=="for" set symbols[!index!]="FOR"
       if /i "!symbol!"=="echo" echo "PRINT symbol: %%a"
       if /i "!symbol!"=="echo" set symbols[!index!]="PRINT"
       if /i "!symbol!"=="(" echo "START BLOCK symbol: %%a"
       if /i "!symbol!"=="(" set symbols[!index!]="START BLOCK"
       if /i "!symbol!"=="EQU" set symbols[!index!]="COMPARATOR"
       if /i "!symbol!"=="NEQ" set symbols[!index!]="COMPARATOR"
       if /i "!symbol!"=="LEQ" set symbols[!index!]="COMPARATOR"
       if /i "!symbol!"=="GEQ" set symbols[!index!]="COMPARATOR"
       if /i "!symbol!"=="GTR" set symbols[!index!]="COMPARATOR"
       if /i "!symbol!"=="LSS" set symbols[!index!]="COMPARATOR"
       if /i "!symbol!"=="==" set symbols[!index!]="COMPARATOR"
       if /i "!symbol!"=="not" set symbols[!index!]="NOT"
       FOR %%s in (%%b) DO (
          set compare=%%s
	  set values[!index!]=!compare!
          set /a "index=index+1"
          set nonvar=!compare:%percen%!
          if "!nonvar!"=="!compare!" set symbols[!index!]="VAR"
          if "!nonvar!"=="!compare!" echo "VAR symbol: %%s"
          if not "!nonvar!"=="!compare!" echo "LITERAL symbol: %%s"
          if not "!nonvar!"=="!compare!" set symbols[!index!]="LITERAL"
       )
         set /a "index=index+1"
         echo "NEW LINE symbol"
         set symbols[!index!]="NEW LINE"
         set /a "index=index+1"
   )
set symbols[!index!]="EOF"
echo painfully verifying grammar....
set openBlockFlag=0
:SemLoop
if defined symbols[%semIndex%] (
call echo checking %%symbols[%semIndex%]%% 
call set sem=%%symbols[%semIndex%]%%
if !sem!=="SCOPESETTINGS" GOTO :scopesettings
if "!sem!"=="ECHOSETTINGS" goto :terminal
if "!sem!"=="IF" goto :continue
if "!sem!"=="MACRO" goto :continue 
if "!sem!"=="JUMP" goto :jump
if "!sem!"=="END BLOCK" goto :endblock
if "!sem!"=="ASSIGN" goto :continue
if "!sem!"=="FOR" goto :continue
if "!sem!"=="PRINT" goto :print
if "!sem!"=="START BLOCK" goto :startblock
if "!sem!"=="EOF" goto :eof
if "!sem!"=="NOT" goto :continue
if "!sem!"=="COMPARATOR" goto :continue
GOTO :continue
:jump
set /a "offset=semIndex+1"
call set nextItem= %%symbols[%semIndex%]%%
if not !nextItem!=="LITERAL" echo Invalid symbol !nextItem!, LITERAL EXPECTED
if not !nextItem!=="LITERAL" GOTO :Error
goto :continue
:print
set /a "offset=semIndex+1"
call set nextItem= %%symbols[%semIndex%]%%
if !nextItem!=="FOR" echo Invalid symbol !nextItem!, LITERAL OR VARIABLE EXPECTED
if !nextItem!=="MACRO" echo Invalid symbol !nextItem!, LITERAL OR VARIABLE EXPECTED
if !nextItem!=="IF" echo Invalid symbol !nextItem!, LITERAL OR VARIABLE EXPECTED
if !nextItem!=="JUMP" echo Invalid symbol !nextItem!, LITERAL OR VARIABLE EXPECTED
if !nextItem!=="ASSIGN" echo Invalid symbol !nextItem!, LITERAL OR VARIABLE EXPECTED
if !nextItem!=="ECHOSETTINGS" echo Invalid symbol !nextItem!, LITERAL OR VARIABLE EXPECTED
if !nextItem!=="SCOPESETTINGS" echo Invalid symbol !nextItem!, LITERAL OR VARIABLE EXPECTED
if !nextItem!=="FOR" GOTO :Error
if !nextItem!=="MACRO" GOTO :Error
if !nextItem!=="IF"  GOTO :Error
if !nextItem!=="JUMP"  GOTO :Error
if !nextItem!=="ASSIGN"  GOTO :Error
if !nextItem!=="ECHOSETTINGS"  GOTO :Error
if !nextItem!=="SCOPESETTINGS"  GOTO :Error
:startblock
set /a "openBlockFlag+=1"
GOTO :continue
:endblock
set /a "openBlockFlag-=1"
GOTO :continue
:scopesettings
set /a "offset=semIndex+1"
call set nextItem= %%symbols[%semIndex%]%%
if not !nextItem!=="LITERAL" echo Invalid symbol !nextItem!, LITERAL EXPECTED
if not !nextItem!=="LITERAL" GOTO :Error
GOTO :continue
:terminal
set /a "offset=semIndex+1"
call set nextItem= %%symbols[%semIndex%]%%
if not !nextItem!=="NEW LINE" echo Invalid symbol !nextItem!, NEW LINE EXPECTED
if not !nextItem!=="NEW LINE" goto :Error
GOTO :continue
:eof
if !openBlockFlag! GTR 0 echo Invalid number of parenthesis, TOO MANY PARENTHESIS:!openBlockFlag! open blocks
if !openBlockFlag! LSS 0 echo Invalid number of parenthesis, TOO FEW PARENTHESIS:!openBlockFlag! open blocks
if !openBlockFlag! GTR 0 GOTO :Error
if !openBlockFlag! LSS 0 GOTO :Error
:continue
echo valid symbol !sem!
set /a "semIndex+=1"
GOTO :SemLoop
)   
echo valid file! converting to c file, slowly and grossly
echo int main(){ > %infile%converted.c
set srcIndex=0
set varIndex=0
:srcLoop
if defined symbols[%srcIndex%] (
call set sr=%%symbols[%srcIndex%]%%
call set vl=%%values[%srcIndex%]%%
if !sr!=="FOR" echo printf("fors not yet supported"); >> %infile%converted.c
if !sr!=="JUMP" echo printf("fors not yet supported"); >> %infile%converted.c
if !sr!=="MACRO" echo printf("macros not yet supported, no linker"); >> %infile%converted.c
if !sr!=="ASSIGN" echo char a%varIndex%[] = "not fully supported"); >> %infile%converted.c
if !sr!=="PRINT" echo printf("!vl!\n"); >> %infile%converted.c
if !sr!=="IF" echo printf("ifs not yet supported"); >> %infile%converted.c
if !sr!=="FOR" echo printf("fors not yet supported"); >> %infile%converted.c
if !sr!=="LITERAL" goto :skip
if !sr!=="COMPARATOR" echo printf("booleans not yet supported"); >> %infile%converted.c
if !sr!=="FOR" echo printf("fors not yet supported"); >> %infile%converted.c
if !sr!=="VAR" echo printf("variables not yet supported"); >> %infile%converted.c
if !sr!=="EOF" GOTO :DONE
:skip
set /a "varIndex+=1"
set /a "srcIndex+=1"
GOTO :srcLoop
)
:DONE
echo } >> %infile%converted.c
gcc %infile%converted.c -o %infile%converted
echo DONE!
pause
echo running c code...
.\%infile%converted
:Error
pause
exit

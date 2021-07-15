//Dvora Riterman 316503267
//Sarah Tordjman 327321196
import ballerina/io;
import ballerina/file;
import ballerina/lang.'int as ints;



///PART 1 TOKENIZING
public type Tokenizing object
{
    function __init(string path, string [] arrLines) returns @tainted error? 
    {
        string writePath = path;
        writePath = path.substring(0, writePath.length()-5);//remove the .jack end
        writePath = writePath +"T.xml"; //add the .asm end

        //creat the new file
        io:WritableByteChannel writableFileResult= check io:openWritableFile(writePath);
        io:WritableCharacterChannel destinationChannel=new(writableFileResult, "UTF-8");

        string writeToXml = "<tokens>\n";
        writeToXml+= classToken(arrLines);
        writeToXml+="</tokens>\n";
        var writeToAsm = destinationChannel.write(writeToXml, 0);  
    }

};  

function split (string line) returns string []
{
    //this func go over the line. char by char and split the line to array of words. if the func recognize Notes or new line -  
    string [] words = [];
    int i=0;//index for words
    int j=0;//index for line
    string word = "";
    while (j<line.length())
    {
        
        if(line[j] =="\"")//in case of string 
        {
            word+=line[j];
            j+=1;
            while(line[j] !="\"")
            {
                word+=line[j];
                j+=1;
            }
            //exit the while because char == " - need to add it to the word
            word+=line[j];
            words[i] = word;//add the string to words arr
            i=i+1;
            j=j+1;
            word="";
        }
        if(line[j]=="/" && line[j+1]=="/")//means its a note in the midle of the line
        {
            break;//out of while - we dond need to continu to read the note
        }
        else if (line[j] != " " && !isSymbol(line[j]) && line[j]!="\n" && line[j].toBytes().toString()!="9") 
        {
            word+=line[j];
            j+=1;           
        }
        else //we got to space or new line = end of one word
        {
            words[i] = word;
            i=i+1;
            word="";
            //line[j] is space or symbol or nl - word contain the word
            if(line[j]==" " || line[j].toBytes().toString()=="9")
            {                
                j+=1;
            }
            else if(isSymbol(line[j]))//we do want to enter synbols to the array
            {
                words[i] = line[j];
                i=i+1;
                j+=1;
            }
            else
            {
                break;
            }
        }
    }
    return words;    
}

function removeSpace(string a) returns string
{
    int i=0;
    int | error x = ints:fromString(a[i].toBytes().toString()); 
    if(a.toBytes().toString()=="13 10" || a.toBytes().toString()=="9 13 10")
    {
        return a;
    }
    if( x is int) 
    {
        while(x<33||x>126)
        {
            i+=1;
            //io:println(a[i].toBytes().toString());
            if(i<a.length()-1)
            {
                x=ints:fromString(a[i].toBytes().toString());
            }
            else//we got to the end of a
            {
                break;
            }
            
        }
    }
    string noSpaces=a.substring(i,a.length());
    return noSpaces;
}

function isKeyword(string symbol) returns boolean
{
    string [] arrSymbol = ["class","constructor","function","method","field","static","var","int","char",
                            "boolean","void","true","false","null","this","let","do","if","else","while","return"];
    foreach var item in arrSymbol {
        if(item ==symbol)
        {
             return true;
        }
    }
    return false;
}

function isSymbol(string symbol) returns boolean
{
    string [] arrSymbol = ["{","}","(",")","[","]",".",",",";","+","-","*","/","&","|","<",">","=","~"];
    foreach var item in arrSymbol {
        if(item ==symbol)
        {
             return true;
        }
    }
    return false;
}

function isIntegerConstant(string symbol) returns boolean
{
    int | error x = ints:fromString(symbol);  
    if(x is int)
    {
        return true;
    }
    else
    {
        return false;
    }
}
function isIdentifier(string symbol) returns boolean
{
    if(symbol.length()==0 || symbol.substring(0,1).toBytes().toString() =="13" ||symbol.substring(0,1).toBytes().toString() =="34"
    ||symbol.toBytes().toString().startsWith("9 ") )
    {
        return false;
    }
    int | error x = ints:fromString(symbol.substring(0,1));  
    if(x is int )
    {
        return false;
    }
    else
    {
        return true;
    }
}

function isStringConstant(string symbol) returns boolean
{
    if(symbol.length()==0)
    {
        return false;
    }
    if(symbol.startsWith("\"") && symbol.endsWith("\""))
    {
        return true;
    }
    return false;
}

function classToken(string [] arrLines) returns string
{
     int i=0;
     string symbol="";
     string returnClassToken="";
     string[] words=[];

     while(i<arrLines.length())
     {
        arrLines[i]= removeSpace(arrLines[i]);    
        if(!arrLines[i].startsWith("//") && !arrLines[i].startsWith("/**") && !arrLines[i].startsWith("*") && !arrLines[i].startsWith("*/")
        && arrLines[i].toBytes().toString()!="13 10" && arrLines[i].toBytes().toString()!="9 13 10")//להתעלם משורות ריקות
        {
            words = split(arrLines[i]); 
            returnClassToken+=printToXml(words);            
            i = i+1;
        }
        else
        {
            i=i+1;      
        } 
    }//end while
    return returnClassToken;
}

function printToXml(string[] words) returns string{
    
    string ret="";
    foreach var word in words 
            {
                if(isKeyword(word))
                {
                    ret+="<keyword> "+ word + " </keyword>\n";

                }
                else if (isSymbol(word)) 
                {
                    if(word =="<")
                    {
                        ret+="<symbol>"+ " &lt; " + "</symbol>\n";
                    }
                    else if(word ==">")
                    {
                        ret+="<symbol>"+ " &gt; " + "</symbol>\n";
                    }
                    else if(word =="&")
                    {
                        ret+="<symbol>"+ " &amp; " + "</symbol>\n";
                    }
                    else
                    {
                        ret+="<symbol> "+ word + " </symbol>\n";
                    }
                }
                else if (isIdentifier(word)) 
                {
                    ret+="<identifier> "+ word + " </identifier>\n";
                }
                else if (isIntegerConstant(word)) 
                {
                    ret+="<integerConstant> " + word + " </integerConstant>\n";
                }
                else if (isStringConstant(word)) 
                {
                    ret+= "<stringConstant> "+word.substring(1, word.length()-1)+" </stringConstant>\n";//print the string without ""
                }
                else 
                {
                    //do nothing - continue
                }

            }
    return ret;

}


///MAIN OF THE PROGRAM
public function main() returns @tainted error? 
{//the FileInfo must use error type - so the main func must return error
    
    string dirName= io:readln("Enter your directory's name:");//שם הספריה עליה עוברים 
    file:FileInfo[]|error readDirFiles=file:readDir(<@untained>  dirName);//רשימה של כל הקבצים בספריה
    int counter=0;
     if(readDirFiles is file:FileInfo[])//if the read file success = is iterable
    {
        foreach var file in readDirFiles 
        {
            ///PART  1 TOKENIZING
            if(file.getName().endsWith(".jack"))
            {       
                //read the file
                io:ReadableByteChannel readableFieldResult = check io:openReadableFile(file.getPath());
                io:ReadableCharacterChannel sourceChannel =new(readableFieldResult, "UTF-8");
            
                //מעבר על הקובץ והמרתו לסטרינג
                string[] arrLines=[];//מערך לשמירת שורות הקובץ
                string readAllStr = "";
                int i=0;
                string line = "";
                string | error char= sourceChannel.read(1);
                boolean notEndOfFile = true;

                //this loop reads the file into a string
                while(notEndOfFile)
                {
                    if(char is string)
                    {
                        readAllStr+=char;
                        char= sourceChannel.read(1);
                    }
                    else//means end of file
                    {
                      notEndOfFile=false;
                    }                      
                  }

                 //this loop breaks the long string into lines - each line in a diferent index 
                 foreach var chr in readAllStr 
                {
                     line+=chr;//add chars until the end of the line
                     if(chr=="\n")
                     {
                         arrLines[i] = line; //if its a new line - enter line into the array
                         line = ""; //reset the line
                         i=i+1;                         
                     }
                }

                Tokenizing |error tokens = new Tokenizing (file.getPath(),arrLines);             
            }
            //PART 2 PARSING
            if(file.getName().endsWith("T.xml"))
            {

                //read the file
                io:ReadableByteChannel readableFieldResult = check io:openReadableFile(file.getPath());
                io:ReadableCharacterChannel sourceChannel =new(readableFieldResult, "UTF-8");
            
                //מעבר על הקובץ והמרתו לסטרינג
                string[] arrLines=[];//מערך לשמירת שורות הקובץ
                string readAllStr = "";
                int i=0;
                string line = "";
                string | error char= sourceChannel.read(1);
                boolean notEndOfFile = true;
                //this loop reads the file into a string
                while(notEndOfFile)
                {
                    if(char is string)
                    {
                        readAllStr+=char;
                        char= sourceChannel.read(1);
                    }
                    else//means end of file
                    {
                      notEndOfFile=false;
                    }                      
                }

                 //this loop breaks the long string into lines - each line in a diferent index 
                 foreach var chr in readAllStr 
                {
                    line+=chr;//add chars until the end of the line
                    if(chr=="\n")
                    {
                        arrLines[i] = line; //if its a new line - enter line into the array
                        line = ""; //reset the line
                        i=i+1;                         
                    }
                }
                 Parsing |error pars = new Parsing (file.getPath(), arrLines);           
            }
            
        }
    }
              
}

///PART 2 PARSER

//global vars
int currentLine=0;//help to find which line we are on now 

public type Parsing object
{
    function __init(string path, string [] arrLines) returns @tainted error? 
    {
        string writePath = path;
        writePath = path.substring(0, writePath.length()-5);//remove the T.xml end
        writePath = writePath +".xml"; //add the .xml end

        //creat the new file
        io:WritableByteChannel writableFileResult= check io:openWritableFile(writePath);
        io:WritableCharacterChannel destinationChannel=new(writableFileResult, "UTF-8");
        currentLine=0;
        string writeToParseXml ="<class>\n";
        currentLine+=1;           //arrLines[0]==<tokens> so we ignore it
        if(arrLines[currentLine]!="</tokens>\n")        
        {
            writeToParseXml+= parseClass(arrLines);
            currentLine+=1;
        }
        writeToParseXml +="</class>\n";
        var writeToAsm = destinationChannel.write(writeToParseXml, 0);              
    }

};

//returns the value of the token 
function tokenValue(string Line) returns string 
{
    //io:println("line: "+currentLine.toString()+" "+Line);
    int i=0;//start of the value
    int j=0;// end of value
    while(Line[i]!=">")
    {
        i+=1;
    }
    i+=1;
    j=i;
    if(j<Line.length()-1)
    {
        while(Line[j]!="<")
        {
        j+=1;
        }
    }
    else {//we got to the end of the file
        return "";
    }
  
    return Line.substring(i+1,j-1);
}

//returns the type of the token 
function tokenType(string Line) returns string 
{
    int i=0;// end of type
    while(Line[i]!=">")
    {
        i+=1;
    }
    return Line.substring(1,i);
}

//this function create the rule class->'class'className'{'classVarDec* subroutineDec*'}'*
function parseClass(string [] arrLines) returns string 
{
    string parseString=arrLines[currentLine];//class
    currentLine+=1;
    parseString+=arrLines[currentLine]; //className
    currentLine+=1;
    parseString+=arrLines[currentLine]; //{
    currentLine+=1;
    while(tokenValue(arrLines[currentLine])=="static" || tokenValue(arrLines[currentLine])=="field")
    {
        parseString+="<classVarDec>\n";
        parseString+= parseClassVarDec(arrLines);
        parseString+="</classVarDec>\n";
    }
    while(tokenValue(arrLines[currentLine])=="constructor" || tokenValue(arrLines[currentLine])=="function" ||
    tokenValue(arrLines[currentLine])=="method")
    {
        parseString+="<subroutineDec>\n";
        parseString+= parseSubroutineDec(arrLines);
        parseString+="</subroutineDec>\n";
    }
    parseString+=arrLines[currentLine];//}      
    currentLine+=1; 
    return parseString;
}

function parseClassVarDec(string [] arrLines) returns string
{
    //('static'|'field')type varName (','varName)* ';'
    string classVarDecString="";
    classVarDecString+=arrLines[currentLine];//field or static
    currentLine+=1;
    classVarDecString+=arrLines[currentLine];//keyword - type of var
    currentLine+=1;
    classVarDecString+=arrLines[currentLine];//identifier - name of var
    currentLine+=1;
    //io:println(arrLines[currentLine]);
    while(tokenValue(arrLines[currentLine])!=";")//, varName)*
    {
       classVarDecString+=arrLines[currentLine];//symbol ,
       currentLine+=1;
       classVarDecString+=arrLines[currentLine];//identifier - name of var
       currentLine+=1;
    }
    classVarDecString+=arrLines[currentLine];//symbol ;
    currentLine+=1;
    return classVarDecString;
}

function parseSubroutineDec(string [] arrLines) returns string
{
    //('constructor'|'function'|'method')('void'|type)subroutineName'('parameterList')'subroutineBody
    string varSubString="";
    varSubString+=arrLines[currentLine];//constructor, function, method
    currentLine+=1;
    varSubString+=arrLines[currentLine];//(void|type)
    currentLine+=1;
    varSubString+=arrLines[currentLine];//subroutineName
    currentLine+=1;
    varSubString+=arrLines[currentLine];//(
    currentLine+=1;
    varSubString+="<parameterList>\n";
    varSubString+= parseParameterList(arrLines);
    varSubString+="</parameterList>\n";
    varSubString+=arrLines[currentLine];//symbol )
    currentLine+=1;
    varSubString+="<subroutineBody>\n";
    varSubString+=parseSubroutineBody(arrLines);
    varSubString+="</subroutineBody>\n";
    return varSubString;
}


function parseParameterList(string [] arrLines) returns string
{
    string paramList="";
    if (isType(tokenValue(arrLines[currentLine])))
    {
        paramList+=arrLines[currentLine];// type
        currentLine+=1;
        paramList+=arrLines[currentLine];//var name
        currentLine+=1;
        while (tokenValue(arrLines[currentLine])==",")
        {
            paramList+=arrLines[currentLine];//,
            currentLine+=1;   
            paramList+=arrLines[currentLine];//type
            currentLine+=1;  
            paramList+=arrLines[currentLine];//varName
            currentLine+=1;           
        }
    }
    return paramList;
}

function isType(string tokenVal) returns boolean 
{
    return (tokenVal=="int"||tokenVal=="char"||tokenVal=="boolean"||tokenVal=="identifier");
}

function parseSubroutineBody(string [] arrLines) returns string
{
    //'{'varDec* statements'}'
    string varBodyString = "";
    //io:println("should be {"+arrLines[currentLine]);
    varBodyString+=arrLines[currentLine];//symbol {
    currentLine+=1;
    while(tokenValue(arrLines[currentLine])=="var")//(var)*
    {
        varBodyString+="<varDec>\n";
        varBodyString+= parseVarDec(arrLines);
        varBodyString+="</varDec>\n";
    }
    varBodyString+="<statements>\n";
    varBodyString+= parseStatements(arrLines);//statements
    varBodyString+="</statements>\n";
    varBodyString+=arrLines[currentLine];//symbol }
    currentLine+=1;
    return varBodyString;
}

function parseVarDec(string [] arrLines) returns string
{
    //'var' type varName (','varName)* ';'
    string varDecString="";
    varDecString+=arrLines[currentLine];//var
    currentLine+=1;
    varDecString+=arrLines[currentLine];//type int|char|boolean....
    currentLine+=1;
    varDecString+=arrLines[currentLine];//varName   
    currentLine+=1;
    while(tokenValue(arrLines[currentLine])==",")//there are more vars in the original line
    {
        varDecString+=arrLines[currentLine];//symbol ,
        currentLine+=1;
        varDecString+=arrLines[currentLine];//identifier - name of var
        currentLine+=1;
    }
    varDecString+=arrLines[currentLine];//symbol ;
    currentLine+=1;
    return varDecString;
}

function isStatement(string tokenVal) returns boolean
{
    //io:println(tokenVal);
    return (tokenVal=="let"||tokenVal=="if"||tokenVal=="while"||tokenVal=="do"||tokenVal=="return");
}

function parseStatements(string [] arrLines) returns string
{
    //statements*
    string statementsString="";
    while(isStatement(tokenValue(arrLines[currentLine])))//statements*
    { 
        statementsString+=parseStatement(arrLines);
    }
    return statementsString;
}

function parseStatement(string [] arrLines) returns string
{
    //letStatement|ifStatement|whileStatement|doStatement|returnStatement
    string stateString="";    
    if(tokenValue(arrLines[currentLine])=="let")
    {
        stateString+="<letStatement>\n";
        stateString+=parseLetStatement(arrLines);
        stateString+="</letStatement>\n";
    }
    else if(tokenValue(arrLines[currentLine])=="if")
    {
        stateString+="<ifStatement>\n";
        stateString+=parseIfStatement(arrLines);
        stateString+="</ifStatement>\n";
    }
    else if(tokenValue(arrLines[currentLine])=="while")
    {
        stateString+="<whileStatement>\n";
        stateString+=parseWhileStatement(arrLines);
        stateString+="</whileStatement>\n";
    }
        else if(tokenValue(arrLines[currentLine])=="do")
    {
        stateString+="<doStatement>\n";
        stateString+=parseDoStatement(arrLines);
        stateString+="</doStatement>\n";
    }
    else if(tokenValue(arrLines[currentLine])=="return")
    {
        stateString+="<returnStatement>\n";
        stateString+=parseReturnStatement(arrLines);
        stateString+="</returnStatement>\n";
    }
    return stateString;
}

function parseLetStatement(string [] arrLines) returns string
{
    //'let' varName ('[' expression ']')? '=' expression ';'
    string letStateString="";
    letStateString+= arrLines[currentLine];//'let'
    currentLine+=1;
    letStateString+= arrLines[currentLine];//varName
    currentLine+=1;
    if (tokenValue(arrLines[currentLine])=="[")//'[' expression ']' 
    {
        letStateString+= arrLines[currentLine];//'['
        currentLine+=1;
        letStateString+="<expression>\n";
        letStateString+= parseExpression(arrLines);//expression
        letStateString+="</expression>\n";
        letStateString+= arrLines[currentLine];//']'
        currentLine+=1;
    }
    letStateString+= arrLines[currentLine];//'='
    currentLine+=1;
    letStateString+="<expression>\n";
    letStateString+= parseExpression(arrLines);//expression
    letStateString+="</expression>\n";
    letStateString+= arrLines[currentLine];//';'
    currentLine+=1;
    return letStateString;
}


function parseIfStatement(string [] arrLines) returns string
{
    //'if' '(' expression ')' '{' statements '}' ('else' '{' statements '}')? 
    string ifStateString="";
    ifStateString+= arrLines[currentLine];//'if'
    currentLine+=1;
    ifStateString+= arrLines[currentLine];//'('
    currentLine+=1;
    ifStateString+="<expression>\n";
    ifStateString+=parseExpression(arrLines);//expression
    ifStateString+="</expression>\n";
    ifStateString+= arrLines[currentLine];//')'
    currentLine+=1;
    ifStateString+= arrLines[currentLine];//'{'
    currentLine+=1;
    ifStateString+="<statements>\n";
    ifStateString+= parseStatements(arrLines);//statements
    ifStateString+="</statements>\n";
    ifStateString+= arrLines[currentLine];//'}'
    currentLine+=1;
    if (tokenValue(arrLines[currentLine])=="else")//else'{'statements'}'
    {
       ifStateString+= arrLines[currentLine];//'else'
       currentLine+=1; 
       ifStateString+= arrLines[currentLine];//'{'
       ifStateString+="<statments>\n";
       ifStateString+= parseStatements(arrLines);//Statements
       ifStateString+="</statments>\n";
       ifStateString+= arrLines[currentLine];//'}'
       currentLine+=1; 
       currentLine+=1; 
    }
    return ifStateString;
}

function parseWhileStatement(string [] arrLines) returns string
{
    //'while' '(' expression ')' '{' statements '}'
    //io:println("enter to while statment " + currentLine.toString());
    string whileStateString="";
    whileStateString+= arrLines[currentLine];//'while'
    currentLine+=1;
    whileStateString+= arrLines[currentLine];//'('
    currentLine+=1;
    whileStateString+="<expression>\n";
    whileStateString+=parseExpression(arrLines);//expression
    whileStateString+="</expression>\n";
    whileStateString+= arrLines[currentLine];//')'
    currentLine+=1;
    whileStateString+= arrLines[currentLine];//'{'
    currentLine+=1;
    whileStateString+="<statements>\n";
    whileStateString+= parseStatements(arrLines);//statements
    whileStateString+="</statements>\n";
    whileStateString+= arrLines[currentLine];//'}'
    currentLine+=1;
    return whileStateString;
}


function parseDoStatement(string [] arrLines) returns string
{
    //'do'subroutineCall';'
    string doStateString="";
    doStateString+= arrLines[currentLine];//'do'
    currentLine+=1;
    doStateString+=parseSubroutineCall(arrLines,true);
    doStateString+= arrLines[currentLine];//';'
    currentLine+=1;   
    return doStateString;
}


function parseReturnStatement(string [] arrLines) returns string
{
    string returnStateString="";
    returnStateString+= arrLines[currentLine];//'return'
    currentLine+=1;
    if(tokenValue(arrLines[currentLine])!=";")
    {
        returnStateString+="<expression>\n";
        returnStateString+=parseExpression(arrLines);
        returnStateString+="</expression>\n";
    }
    returnStateString+= arrLines[currentLine];//';'
    currentLine+=1;
    return returnStateString;
}

function parseExpression(string [] arrLines) returns string
{
    //io:println("enter to Expression " +currentLine.toString());
    //term (op term)*
    string expression="";
    //term
    expression+="<term>\n";
    expression+=parseTerm(arrLines);
    expression+="</term>\n";

    //op - optional
    while (isOp(tokenValue(arrLines[currentLine])))
    {
        //io:println("enter to if op " +currentLine.toString() );
        expression+= arrLines[currentLine];//'op'
        currentLine+=1; 
        //another term
        expression+="<term>\n";
        expression+=parseTerm(arrLines);
        expression+="</term>\n";    
    }
    return expression;
}


function parseTerm(string [] arrLines) returns string
{
    //io:println("enter to term " +currentLine.toString());
    //integerConstant|stringConstant|keyword|varName|varName'['expression']'|subroutineCall|'('expression')'|unaryOp term
    string term="";
    if(tokenType(arrLines[currentLine])=="integerConstant" || tokenType(arrLines[currentLine])=="stringConstant" || tokenType(arrLines[currentLine])=="keyword")
    {
        term+= arrLines[currentLine];//print type
        currentLine+=1;
    }
    else if (tokenValue(arrLines[currentLine])=="(") //(expression)
    {
        term+= arrLines[currentLine];//(
        currentLine+=1;
        term+="<expression>\n";
        term+=parseExpression(arrLines);
        term+="</expression>\n";
        term+= arrLines[currentLine];//)
        currentLine+=1;
    }
    else if (tokenValue(arrLines[currentLine])=="-" || tokenValue(arrLines[currentLine])=="~") //unaryOp term
    {
        term+= arrLines[currentLine];//unaryOp
        currentLine+=1;
        term+="<term>\n";
        term+=parseTerm(arrLines);
        term+="</term>\n";
    }
    else //start with identifier check if match to one of these rules term->varName|varName'['expression']'|subroutineCall 
    {
        //io:println("line: "+currentLine.toString()+" "+arrLines[currentLine]);
        term+= arrLines[currentLine];//identifier
        currentLine+=1;
        if(tokenValue(arrLines[currentLine])=="[")//'['expression']'
        {
            term+= arrLines[currentLine];//'['
            currentLine+=1;
            term+="<expression>\n";
            term+=parseExpression(arrLines);
            term+="</expression>\n";
            term+= arrLines[currentLine];//']'
            currentLine+=1;
        }
        else if (tokenValue(arrLines[currentLine])=="(" || tokenValue(arrLines[currentLine])==".")
        {
            term += parseSubroutineCall(arrLines , false);
        }
    }
    //io:println(term);
    return term;
}


function isOp(string tokenVal) returns boolean
{
    //checks if is opperation
    return (tokenVal=="+"||tokenVal=="-"||tokenVal=="*"||tokenVal=="/"||tokenVal=="&amp;"||
            tokenVal=="|"||tokenVal=="&gt;"||tokenVal=="&lt;"||tokenVal=="=");
}


function parseSubroutineCall(string [] arrLines ,  boolean flagToPrint) returns string
{
    //subroutineName'('expressionList')'|(className|varName)'.'subroutineName'('expressionList')'
    string subroutinCall= "";
    if (flagToPrint) //if flag=true it prints the identifier
    {
        subroutinCall+= arrLines[currentLine];//identifier subroutineName or (className|varName)
        currentLine+=1;
    }
    if(tokenValue(arrLines[currentLine])==".")//'.' subroutineName
    {
        subroutinCall+= arrLines[currentLine];//'.'
        currentLine+=1;
        subroutinCall+= arrLines[currentLine];//identifier
        currentLine+=1;
    }
    //'('expressionList')'
    subroutinCall+= arrLines[currentLine];//'('
    currentLine+=1;
    subroutinCall+="<expressionList>\n";
    subroutinCall+= parseExpressionList(arrLines);
    subroutinCall+="</expressionList>\n";
    subroutinCall+= arrLines[currentLine];//')'
    currentLine+=1;
    return subroutinCall;
}


function parseExpressionList(string [] arrLines) returns string
{
    //(expression(','expression)* )?
    string exList="";
        
    if(isTerm(arrLines[currentLine]))
    {
        exList+="<expression>\n";
        exList+=parseExpression(arrLines);
        exList+="</expression>\n";
        while (tokenValue(arrLines[currentLine])==",")
        {
            exList+= arrLines[currentLine];//','
            currentLine+=1;
            exList+="<expression>\n";
            exList+=parseExpression(arrLines);
            exList+="</expression>\n";
        }
    }
    //io:println(exList);
    return exList;
}


function isTerm(string Line) returns boolean
{
    string tokenType1 = tokenType(Line);
    string tokenValue1 = tokenValue(Line);
    return (tokenType1=="integerConstant"||tokenType1=="stringConstant"||tokenType1=="keyword"||tokenValue1=="(" 
            ||tokenValue1=="-"|| tokenValue1=="~"||tokenType1=="identifier");
}











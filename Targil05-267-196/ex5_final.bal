//Sarah Tordjman 327321196
//Dvora Riterman 316503267
import ballerina/io;
import ballerina/file;
import ballerina/lang.'int as ints;

public type SymbolElement object
 {
    public string mtype = "";
    public string kind = "";
    public string name = "";
    public int mIndex = 0;

      function __init(string _name, string _kind, string _mtype, int _mIndex) {
        self.mtype = _mtype;
        self.kind = _kind;
        self.name = _name;
        self.mIndex = _mIndex;
      }
  };

public type SymbolTable object
 {
    public int lclCounter = 0;
    public int argCounter = 0;
    public int staticCounter = 0;
    public int fieldCounter = 0;
    SymbolElement[] symbolList =[];

    function __init() 
    {
        self.reset();
    }
   public function reset()
    {
      self.lclCounter = 0;
      self.argCounter = 0;
      self.staticCounter = 0;
      self.fieldCounter = 0;
      self.symbolList =[];
    }
    public function define(string _name, string _kind, string _mtype)
       {
         int i = 0;
         match _kind
         {
            "field" => 
             { 
                i = self.fieldCounter;
                self.fieldCounter += 1;
             }
              "static" => 
             { 
                i = self.staticCounter;
                self.staticCounter += 1;
             }
              "argument" => 
             { 
                i = self.argCounter;
                self.argCounter += 1;
             }
              "local" => 
             { 
                i = self.lclCounter;
                self.lclCounter += 1;
             }
         }
        
        self.symbolList.push(new SymbolElement(_name,_kind,_mtype,i) );
        
      } 
 public function kindOf(string _name) returns string
 {
    string res="null";
    
    foreach var item in self.symbolList
     {
         if(item.name== _name )
         {
             res = item.kind;
             return res;
         }
     }   
    return res;
  } 
  public function indexOf(string _name) returns int
 {
    int res= -1;
    
    foreach var item in self.symbolList
     {
         if(item.name== _name )
         {
             res = item.mIndex;
             return res;
         }
     }   
    return res;
  } 
  public function typeOf(string _name) returns string
 {
    string res="null";
    
    foreach var item in self.symbolList
     {
         if(item.name== _name )
         {
             res = item.mtype;
             return res;
         }
     }   
    return res;
  } 
  public function varCount(string _kind) returns int
 {
    match _kind
         {
            "field" => 
             { 
               return self.fieldCounter;
             }
              "static" => 
             { 
                return self.staticCounter;
             }
              "argument" => 
             { 
               return self.argCounter;
             }
              "local" => 
             { 
                return self.lclCounter;
             }
         }
        
         io:println("error varCount");
         return -1;
 } 

};

int currentLine = 0;
int saveLine = 0;
int labelIndex = 0;
SymbolTable classTable = new();
SymbolTable functionTable = new();

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

function isOp(string tokenVal) returns boolean
{
    //checks if is opperation
    return (tokenVal=="+"||tokenVal=="-"||tokenVal=="*"||tokenVal=="/"||tokenVal=="&amp;"||
            tokenVal=="|"||tokenVal=="&gt;"||tokenVal=="&lt;"||tokenVal=="=");
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
            //PART 2 VMPARSING
            //add the call to vmParsing(arrLines)          
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

//PART 2

public type Parsing object
{
    function __init(string path, string [] arrLines) returns @tainted error? 
    {
        string writePath = path;
        writePath = path.substring(0, writePath.length()-5);//remove the T.xml end
        writePath = writePath +".vm"; //add the .vm end

        //creat the new file
        io:WritableByteChannel writableFileResult= check io:openWritableFile(writePath);
        io:WritableCharacterChannel destinationChannel=new(writableFileResult, "UTF-8");
        
        //create the file tables
        classTable = new();
        functionTable = new(); 
        currentLine=1;//tokens

        string writeToParseVm =vmParsing(arrLines);
        var writeToVm = destinationChannel.write(writeToParseVm, 0);              
    }

};

//returns the value of the token 
function tokenValue(string Line) returns string 
{
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

public function vmParsing(string [] lines) returns string
{
    
    string vmOutPut = "";
    string className ="";
    string value ="";
    string markup ="";
    currentLine+=1;
    className = tokenValue(lines[currentLine]);
    currentLine+=1;
    currentLine+=1;
    value = tokenValue(lines[currentLine]);
    while (value == "static" || value == "field")
    {
        compileClassVarDec(lines);         
        currentLine+=1;
        value = tokenValue(lines[currentLine]);
    }
    value = tokenValue(lines[currentLine]);
    while (value == "constructor" || value == "function" || value == "method")
    {
        vmOutPut+= compileSubroutineDec(lines , className); 
        currentLine+=1;
        value = tokenValue(lines[currentLine]);
    }
    return vmOutPut;
}
function compileClassVarDec(string[] lines) 
{//adds the class var to the table

    string Type = "";
    string Kind = "";
    string Name = "";
    string value = "";

    Kind = tokenValue(lines[currentLine]);// static / field
    currentLine+=1;
    Type = tokenValue(lines[currentLine]);
    currentLine+=1;
    Name = tokenValue(lines[currentLine]);
    classTable.define(Name, Kind, Type);
    currentLine+=1; // , or ;
    value = tokenValue(lines[currentLine]);
    while (value != ";") //same kind
    {
      currentLine+=1; 
      Name = tokenValue(lines[currentLine]);
      classTable.define(Name, Kind, Type);
      currentLine+=1;  // , or ;
      value = tokenValue(lines[currentLine]);
    }

}

function compileSubroutineDec(string[] lines , string className) returns string
{// take cares of all the class function/method/constructor
    string vmOutPut="";  
    string kind = tokenValue(lines[currentLine]);
    string name = "";
    string value = "";
    functionTable.reset();
    if (kind == "method") 
    {
      functionTable.define("this", "argument", className);
    }
    currentLine+=1; 
    currentLine+=1; 
    name = className + "." + tokenValue(lines[currentLine]);
    currentLine+=1;
    compileParametersList(lines);
    currentLine+=1;
    currentLine+=1;
    value =  tokenValue(lines[currentLine]);
    while (value == "var") 
    {
      compileVarDec(lines);
      currentLine+=1;
      value =  tokenValue(lines[currentLine]);
    }
    //write to VM
    vmOutPut += "function " + name + " " + functionTable.varCount("local").toString() + "\n";
    if (kind == "constructor")
     {
      vmOutPut+="push constant " + classTable.varCount("field").toString() + "\n";
      vmOutPut+="call Memory.alloc 1\n";
      vmOutPut+="pop pointer 0\n";
    }
    if (kind == "method") {
      vmOutPut+="push argument 0\n";
      vmOutPut+="pop pointer 0\n";
    }
    vmOutPut += compileStatment(lines, className);
    //L2
    currentLine+=1;
    return vmOutPut;
}

function compileParametersList(string[] lines) 
{// add all the functions arguments (...) to the table
    var mtype="";
    var name ="";
    var value = "";
    value = tokenValue(lines[currentLine]);
    while (value != ")")
    {
        currentLine+=1;
        value = tokenValue(lines[currentLine]); //type token
        if (value != ")")
        {
            mtype = tokenValue(lines[currentLine]);
            currentLine+=1;
            value = tokenValue(lines[currentLine]); // name token
            name = tokenValue(lines[currentLine]);
            functionTable.define(name, "argument", mtype);
            currentLine+=1;
            value = tokenValue(lines[currentLine]); // , or ) token
        }     
    }
}
  
function compileVarDec(string [] lines) 
{//adds all the functions local values to the table
    string mtype = "";
    string name = ""; 
    currentLine+=1;
    mtype = tokenValue(lines[currentLine]);
    string value = "";
    value = tokenValue(lines[currentLine]);
    while (value != ";") 
    {
      currentLine+=1;
      name = tokenValue(lines[currentLine]);
      functionTable.define(name, "local", mtype);
      currentLine+=1;// , or ;
      value = tokenValue(lines[currentLine]);
    }
}

function compileStatment(string[] lines,string className) returns string 
{// the body of the func after all the vars
    string temp = "";
    string value = tokenValue(lines[currentLine]);
    string markup = tokenType(lines[currentLine]);
    boolean isMark = false; 
    while (value != "}")
    {
        match value
        {
            "let" => 
            { 
                temp+= compileLetStatment(lines ,className);            
            }
            "do" => 
            { 
                temp+=compileSubroutineCall(lines,className);
                temp+="pop temp 0\n"; // pop the unused return value
                currentLine+=1; 
                value = tokenValue(lines[currentLine]);
            }
            "while" =>
            { 
                temp+=compileWhileStatment(lines, className);
            }
            "if" =>
            { 
                temp += compileIfStatment(lines, className);                  
            }
            "return" =>
            { 
                temp += compileReturnStatment(lines, className);
            } 
        }
        saveLine = currentLine;
        isMark = true;
        currentLine+=1;
        value = tokenValue(lines[currentLine]);
    }
    if (isMark) 
    {
        currentLine = saveLine; 
    }
    return temp;
}

function compileLetStatment(string[] lines ,string className) returns string
{
    string vmOutPut=""; 
    currentLine+=1;// id token
    string id = tokenValue(lines[currentLine]);
    currentLine+=1; // [ or = token
    string value = tokenValue(lines[currentLine]);
    if (value == "[") 
    {
      vmOutPut += compileExpressions(lines ,className);// [expr]
      vmOutPut += pushVarName(id);
      vmOutPut+="add\n";
      currentLine+=1; // ] token
      currentLine+=1; // = token
      vmOutPut += compileExpressions(lines ,className); // right side
      vmOutPut+="pop temp 0\n";
      vmOutPut+= "pop pointer 1\n";
      vmOutPut+="push temp 0\n";
      vmOutPut+="pop that 0\n";
    } 
    else 
    {
      vmOutPut += compileExpressions(lines ,className);// right side
      //L4
      vmOutPut += popToVarName(id);
    }
    currentLine+=1; // ; token
    return vmOutPut;
}
function compileExpressions(string[] lines,string className) returns string
{
    string temp = "";
    string value = "";
    temp+= compileTerm(lines,className); 
    saveLine = currentLine;// mark the reader
    currentLine+=1;
    value = tokenValue(lines[currentLine]); // op token
    while (isOp(value))
    {
        value = tokenValue(lines[currentLine]);
        temp+= compileTerm(lines,className);
        match value
        {
            "+" => 
            { 
                temp += "add\n";
            }
            "-" => 
            { 
               temp += "sub\n";
            }
            "*" =>
            { 
                temp += "call Math.multiply 2\n";
            }
            "/" =>
            { 
                temp += "call Math.divide 2\n";              
            }
            "&amp;" =>
            { 
                temp += "and\n";
            } 
            "|" =>
            { 
                temp += "or\n";                
            }
            "&lt;" =>
            { 
               temp += "lt\n";
            } 
            "&gt;" =>
            { 
               temp += "gt\n";                 
            }
            "=" =>
            { 
                temp += "eq\n";
            } 
        } 
        saveLine = currentLine;
        currentLine+=1;
        value = tokenValue(lines[currentLine]); // op or somthig else
    }
    currentLine = saveLine;
    return temp;
}

function compileTerm(string[] lines,string className) returns string
{
    currentLine+=1;
    string temp ="";
    string markup=tokenType(lines[currentLine]);
    string value = tokenValue(lines[currentLine]);
    if (markup == "integerConstant")
    {
      temp += "push constant " + value + "\n";
    } 
    else if (markup == "stringConstant") 
    {
        int vLength = value.length();
        temp += "push constant " + vLength.toString() + "\n";
        temp += "call String.new 1\n";
        int stop = 0;
        foreach var eachChar in value
        {
            var ascii = eachChar.getCodePoint(0);
            temp += "push constant " + ascii.toString() + "\n";
            temp += "call String.appendChar 2\n"; 
        }
    }
    else if (markup == "keyword")
    {
        if (value == "null" || value == "false")
        {
            temp += "push constant 0\n";//ל
        }   
        if (value == "true")
        {
            temp += "push constant 0\n";
            temp += "not\n";
        }   
        if (value == "this")
        {
            temp += "push pointer 0\n";
        }     
       
    } 
    else if (markup == "identifier")
    {
        var id = value; // var name
        saveLine = currentLine;
        string[] saveToken =[];
        saveToken[0]= markup;
        saveToken[1]= value;
        currentLine+=1; 
        value = tokenValue(lines[currentLine]);
        if (value == "[") 
        {
            temp += compileExpressions(lines ,className);
            temp += pushVarName(id);
            temp += "add\n";
            temp += "pop pointer 1\n";
            temp += "push that 0\n";
            currentLine+=1;
            value = tokenValue(lines[currentLine]);// ] token
        } 
    else if (value == "(") 
    {
        temp += compileSubroutineCall(lines, className);
        currentLine+=1;
        value = tokenValue(lines[currentLine]);// ) token
    }
    else if (value == ".")
    {
        currentLine = saveLine;
        markup = saveToken[0];
        value = saveToken[1];
        temp += compileSubroutineCall(lines, className);  
    } 
    else 
    {
        temp += pushVarName(id);
        currentLine = saveLine;//return one char back, to the point we marked earlier
    }
    }
    else if (value == "(")
    {
        temp += compileExpressions(lines ,className) ;
        currentLine+=1;
        value = tokenValue(lines[currentLine]);// ) token
    } 
    else if (value == "-"|| value == "~")
    {
        var op = value;
        temp += compileTerm(lines, className);
        if (op == "-")
        {
            temp += "neg\n";
        }        
        else
        {
           temp += "not\n";
        }
    }
    return temp;
}

function pushVarName(string id) returns string
{
    string temp = "";
    var kind = functionTable.kindOf(id);
    if (kind == "null")
    {
        kind = classTable.kindOf(id);
    }
    if (kind == "local" || kind == "argument")
    {
      temp += "push " + kind + " " + functionTable.indexOf(id).toString() + "\n";
    }
    else 
    {
        if (kind == "field")
        {
            temp += "push this " + classTable.indexOf(id).toString() + "\n";
        } 
        else//static
        {
            temp += "push static " + classTable.indexOf(id).toString() + "\n";
        } 
    }
    return temp;
}

//check
function popToVarName(string id) returns string
{
    string temp = "";
    var kind = functionTable.kindOf(id);
    if (kind == "null")
    {
        kind = classTable.kindOf(id);
    } 
    if (kind == "local" || kind == "argument")
    {
        temp += "pop " + kind + " " + functionTable.indexOf(id).toString() + "\n";
    }
    else 
    {
        if (kind == "field")
        {
            temp += "pop this " + classTable.indexOf(id).toString() + "\n";
        }
        else //static
        {
           temp += "pop static " + classTable.indexOf(id).toString() + "\n";
        }
    }
    return temp;
}

function compileSubroutineCall(string[] lines, string className, boolean writeMainMarkup = true) returns string
{
    string temp ="";
    string markup=tokenType(lines[currentLine]);
    string value = tokenValue(lines[currentLine]);
    if (markup != "identifier") 
    {
        currentLine+=1; //read the name of function token
    }
    boolean isMethod = true;
    string name = tokenValue(lines[currentLine]);
    string kind ="";
    string mtype ="";
    int i = 0;
    kind = functionTable.kindOf(name);
    if (kind != "null")
    {
       mtype = functionTable.typeOf(name);
       i = functionTable.indexOf(name);
    } 
    else 
    {
        kind = classTable.kindOf(name);
        mtype = classTable.typeOf(name);
        i = classTable.indexOf(name);
    }
    currentLine+=1; // ( or . token
    value = tokenValue(lines[currentLine]);
    if (value == ".")
    {
        if (kind != "null") 
        {
            currentLine +=1;// id
            value = tokenValue(lines[currentLine]);
            name = value;
            if (mtype == className)
            {
                temp += "push pointer 0" + "\n";// push this
            } 
            else
            {
                if(kind == "argument" || kind == "local")
                {
                    temp +="push " + kind + " " + i.toString() + "\n";
                }
                if(kind == "field")
                {
                    temp += "push this " + i.toString() + "\n";
                }
                if(kind == "static")
                {
                    temp += "push static " + i.toString() + "\n";
                }
          
            }
        }
        else
        {
            isMethod = false;
            mtype = name;
            currentLine+=1;// id
            value = tokenValue(lines[currentLine]);
            name = value;
        }
        currentLine+=1;
        value = tokenValue(lines[currentLine]);// ( token  
    }
    else if (value == "(") // func() of current class
    { 
        temp += "push pointer 0" + "\n"; // push this
        mtype = className;
    }
    string[]res = compileExpressionList(lines,className);
    temp+= res[0];
    int | error argc = ints:fromString(res[1]);
    if (isMethod && argc is int)
    {      
        argc+=1;
    } 
    currentLine+=1;
    value = tokenValue(lines[currentLine]);// ) token
    temp += "call " + mtype + "." + name + " " + argc.toString() + "\n";
    return temp; 
}

function compileExpressionList(string[] lines ,string className) returns string[] 
{
    string temp = "";
    string value="";
    int argc = 0;
    saveLine = currentLine;
    currentLine+=1;
    value = tokenValue(lines[currentLine]);
    if (value == ")") 
    {
        currentLine = saveLine;
    } 
    else
    {
        argc = argc + 1;
        currentLine = saveLine;
        temp += compileExpressions(lines ,className);
        saveLine = currentLine;
        currentLine+=1;
        value = tokenValue(lines[currentLine]);
        while (value == ",") 
        {
            argc = argc + 1;
            temp += compileExpressions(lines ,className);
            saveLine = currentLine;
            currentLine+=1;
            value = tokenValue(lines[currentLine]);// ) or , token
        }
        currentLine = saveLine;
    }
    string []arr = [temp,argc.toString()];
    return arr;
}

function compileWhileStatment(string[] lines, string className) returns string
{
    string temp = "";
    string beginLabel = "whileStatement_"+labelIndex.toString()+"_st";
    string endLabel = "whileStatement_"+labelIndex.toString()+"_end";
    labelIndex+=1;
    temp+="label "+ beginLabel + "\n";

    currentLine+=1;// ( token
    temp += compileExpressions(lines ,className);
    temp+="not" + "\n";
    currentLine+=1;/// ) token

    temp+="if-goto " +endLabel + "\n";

    currentLine+=1;// { token
    temp+=compileStatment(lines,className);
    temp+="goto " + beginLabel + "\n";
    temp+="label "+ endLabel + "\n";
    currentLine+=1;// } token
    return temp;
}

function compileIfStatment(string[] lines, string className)   returns string
{
    string temp="";
    string beginElseLabel = "ifStatement_"+labelIndex.toString()+"_else";
    string endElseLabel = "ifStatement_"+labelIndex.toString()+"_end";
    string value ="";
    string markup ="";
    labelIndex+=1;

    currentLine+=1; // ( token

    temp += compileExpressions(lines, className);
    temp += "not" + "\n";
    temp += "if-goto " + beginElseLabel + "\n";
    currentLine+=1;// ) token

    currentLine+=1;// { token

    temp += compileStatment(lines, className);
    currentLine+=1;// } token

    temp += "goto " + endElseLabel + "\n";
    temp += "label " + beginElseLabel + "\n";
    saveLine = currentLine;// mark the reader
    currentLine+=1;
    value = tokenValue(lines[currentLine]);
    markup = tokenType(lines[currentLine]);
    if (markup == "keyword" && value == "else") 
    { // then there is also "else"
        currentLine+=1;// { token
        temp += compileStatment(lines, className);
        currentLine+=1;// } token// } token
    }
    else 
    {
        currentLine = saveLine;
    }
    temp += "label " + endElseLabel + "\n";
    return temp;
}

function compileReturnStatment(string[] lines, string className) returns string
{
    string temp="";
    saveLine= currentLine;// mark the reader
    currentLine+=1;// expr or ; token
    string value ="";
    string markup ="";
    value = tokenValue(lines[currentLine]);
    markup = tokenType(lines[currentLine]);
    if (!(markup == "symbol" && value == ";"))//its not ";" yet-so there is expression
    {
        currentLine = saveLine;
        temp += compileExpressions(lines, className);
    }
    else
    {
        temp +=  "push constant 0\n";
    }
    temp +=  "return\n";
    return temp;
}

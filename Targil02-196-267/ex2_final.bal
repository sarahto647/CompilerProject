//Dvora Riterman 316503267
//Sarah Tordjman 327321196
import ballerina/io;
import ballerina/file;
import ballerina/lang.'int as ints;


public function findValueRest(string line) returns string
{
    string nameOfString = "";
    foreach var chr in line {
        if(chr!=" "&& chr.toBytes().toString()!="13" && chr!="\\")
            {
                nameOfString+=chr;   
            }
        else 
            {
                break;
            }              
    }
    return nameOfString;
        //for some reason the last char is equal to \n
}

public function push (string line, string nameOfFile) returns string{
    string strReturn = "";
 /////// GROUP 1///////
    //LOCAL
     if( line.startsWith("local"))
     {
        //finding the value of x without the rest of the line
            string subString = line.substring(6,line.length());
            string valueStr = findValueRest(subString);
        strReturn += "@"+valueStr+"\nD=A\n"+"@LCL"+"\nA=M+D\nD=M\n@SP\nA=M\nM=D\n";
     }//end of local
    //ARGUMENT
     if( line.startsWith("argument"))
     {
        //finding the value of x without the rest of the line
            string subString = line.substring(9,line.length());
            string valueStr = findValueRest(subString);
        strReturn += "@"+valueStr+"\nD=A\n"+"@ARG"+"\nA=M+D\nD=M\n@SP\nA=M\nM=D\n";
     }//end of argument
    //THIS
     if( line.startsWith("this"))
     {
        //finding the value of x without the rest of the line
            string subString = line.substring(5,line.length());
            string valueStr = findValueRest(subString);
        strReturn += "@"+valueStr+"\nD=A\n"+"@THIS"+"\nA=M+D\nD=M\n@SP\nA=M\nM=D\n";
     }//end of this
    //THAT
     if( line.startsWith("that"))
     {
         //finding the value of x without the rest of the line
            string subString = line.substring(5,line.length());
            string valueStr = findValueRest(subString);
        strReturn += "@"+valueStr+"\nD=A\n"+"@THAT"+"\nA=M+D\nD=M\n@SP\nA=M\nM=D\n";
     }//end of that
 /////// GROUP 2///////
   //TEMP
    if( line.startsWith("temp"))
    {
        //finding the value of x without the rest of the line
            string subString = line.substring(5,line.length());
            string valueStr = findValueRest(subString);
        strReturn += "@5\n"+"D=A\n"+"@"+valueStr+"\nA=D+A\nD=M\n@SP\nA=M\nM=D\n";
    }
 /////// GROUP 3///////
   //STATIC
    if(line.startsWith("static"))
     {
         //finding the value of x without the rest of the line
            string subString = line.substring(7,line.length());
            string valueStr = findValueRest(subString);
         strReturn+="@"+nameOfFile+"."+valueStr+"\nD=M\n@SP\nA=M\nM=D\n";//A - save the address of this
     }
 /////// GROUP 4///////
   //POINTER 0
    if( line.startsWith("pointer 0"))
    {
        strReturn+="@THIS\n";//save in A the address of this
        strReturn+="D=M\n";//D save the value in the address
        strReturn+="@SP\n";//A=0
        strReturn+="A=M\n";//A save the next empty
        strReturn+="M=D\n";//push into the stack
    }
   //POINTER 1
    if( line.startsWith("pointer 1"))
    {
        strReturn+="@THAT\n";//save in A the address of that
        strReturn+="D=M\n";//D save the value in the address
        strReturn+="@SP\n";//A=0
        strReturn+="A=M\n";//A save the next empty
        strReturn+="M=D\n";//push into the stack
    }

 /////// GROUP 5///////
   //CONSTANT
    if( line.startsWith("constant"))
    {//constant - means to enter the value to the top of the stack
    //finding the value of x without the rest of the line
            string subString = line.substring(9,line.length());
            string valueStr = findValueRest(subString);
         strReturn += "@"+valueStr+"\nD=A"+"\n"+"@SP\nA=M\nM=D\n";//@value
    }//end of constant
 /////THE END FOR ALL CASSES/////
    return strReturn+"@SP"+"\n"+"M=M+1\n";//SP++
} //end push

public function pop(string line, string nameOfFile) returns string
{ 
    string strReturn="";
    strReturn += "@SP\n";//A=0
    strReturn +="A=M-1\n";//A = RAM[A]-1= save in A the address of the top value in the stack
    strReturn +="D=M\n";//D save the top value in the stack
 ///////// GROUP 1/////////////////
    //LOCAL
        if(line.startsWith("local"))//pop local x pop the top of the stack into address RAM[RAM[LCL] + x ]	LCL =1
        {
            string subString = line.substring(6,line.length());
            string valueStr = findValueRest(subString);
        int | error x = ints:fromString(valueStr);        
         if(x is int)
         {
           strReturn +="@LCL\n";//A=1
           strReturn+="A=M\n";//A=RAM[A] = RAM[1]+x - save in A the address of the local segmant
           int i =0;
           while (i<x)//addind the value to the local address - RAM[LCL] + x 
            {
             strReturn +="A=A+1\n";
             i=i+1;
            }
         }
        else
         {
            io:println("error x isnt int local pop");
         }
        }//end if local
         
    //ARGUMENT
        if(line.startsWith("argument"))
        {
            string subString = line.substring(9,line.length());
            string valueStr = findValueRest(subString);
            int | error x = ints:fromString(valueStr);
            if(x is int)
            {
                strReturn +="@ARG\n";//A=2
                strReturn+="A=M\n";//A=RAM[A] = RAM[1]+x - save in A the address of the local segmant
                int i=0;
                while (i<x)//addind the value to the local address - RAM[ARG] + x 
                 {
                     strReturn+="A=A+1\n";
                     i=i+1;
                 }
            }
             else
            {
             io:println("error argumant pop");
            }
        }//end if arg

    //THIS
        if(line.startsWith("this"))
        { 
            string subString = line.substring(5,line.length());
            string valueStr = findValueRest(subString);
            int | error x = ints:fromString(valueStr);
            if(x is int)
            {
                strReturn +="@THIS\n";//A=3
                strReturn+="A=M\n";//A=RAM[A] = RAM[1]+x - save in A the address of the local segmant
                int i=0;
                while (i<x)//addind the value to the local address - RAM[THIS] + x 
                 {
                     strReturn+="A=A+1\n";
                     i=i+1;
                 }
            }
             else
            {
             io:println("error this pop");
            }
        }//end if this

    //THAT
        if(line.startsWith("that"))
        { //finding the value of x without the rest of the line
            string subString = line.substring(5,line.length());
            string valueStr = findValueRest(subString);
            int | error x = ints:fromString(valueStr);
            if(x is int)
            {
                strReturn +="@THAT\n";//A=4
                strReturn+="A=M\n";//A=RAM[A] = RAM[1]+x - save in A the address of the local segmant
                int i=0;
                while (i<x)//addind the value to the local address - RAM[THAT] + x 
                 {
                     strReturn+="A=A+1\n";
                     i=i+1;
                 }
            }
             else
            {
             io:println("error that pop");
            }
        }//end if that

 //////// GROUP 2///////////////////
    //TEMP
     if(line.startsWith("temp"))
      {//finding the value of x without the rest of the line
            string subString = line.substring(5,line.length());
            string valueStr = findValueRest(subString);
            int | error x = ints:fromString(valueStr);
          if(x is int)
            {
                //strReturn +="@TEMP\n";//A=constant value of 5
                strReturn +="@5\n";//A=constant value of 5
                strReturn+="A=M\n";//A=RAM[A] = RAM[1]+x - save in A the address of the local segmant
                int num = x+5;
                strReturn+="@"+num.toString()+"\n";//addind the x to the address RAM[ 5 + x ]      
            }
             else
            {
             io:println("error temp pop");
            }
        }//end if temp

 //////// GROUP 3///////////////////
    //STATIC
     if(line.startsWith("static"))
      {//pop static x - pop the top of the stack into address RAM[className.x ]	All  static variables are saved on RAM[16-255]
         strReturn+="@"+nameOfFile+"."+line.substring(7, line.length());//A - save the address of this
      }
 //////// GROUP 4///////////////////
    //POINTER 0
     if(line.startsWith("pointer 0"))
      {
         strReturn+="@THIS\n";//A - save the address of this
      }
    //POINTER 1
      if(line.startsWith("pointer 1"))
     {
         strReturn+="@THAT\n";//A - save the address of this
     }
 //////// THE END FOR ALL CASSES ///////////////////
    strReturn+="M=D\n";//D is the value to pop - M=D copy the value into memory
    return strReturn+"@SP"+"\n"+"M=M-1\n";//SP--
        
}//end pop 

public function add() returns string
{
    string strReturn="";
    strReturn+="@SP\n";//A=0 - A points to the next empty location in the stack
    strReturn+="A=M-1\n";//A=RAM[A]-1 - A points to the last value in the stack
    strReturn+="D=M\n";//D=RAM[A] - D contains the  last value in the stack
    strReturn += "A=A-1\n";//A points to the second last value
    strReturn +="M=D+M\n";//M contains the sum of the two - and push to the stack
    return strReturn+"@SP\nM=M-1\n";//SP--
} //end add

public function sub() returns string
{
    string strReturn="";
    strReturn+="@SP\n";//A=0 - A points to the next empty location in the stack
    strReturn+="A=M-1\n";//A=RAM[A]-1 - A points to the last value in the stack
    strReturn+="D=M\n";//D=RAM[A] - D contains the  last value in the stack
    strReturn += "A=A-1\n";//A points to the second last value
    strReturn +="M=M-D\n";//M contains the sub of the two - and push to the stack
    return strReturn+"@SP\nM=M-1\n";//SP--
} //end sub

public function eq() returns string
{
    string strReturn="@SP\n";
    strReturn += "A=M-1\n";//A is the address of the top value
    strReturn += "D=M\n";//D is the top value
    strReturn += "A=A-1\n";//A is the address of the first value to compare
    strReturn += "D=D-M\n";//D is the sub between the two top values - if eq - D=0
    strReturn += "@IF_TRUE_1\n";
    strReturn+="D;JEQ\n";//if D=0 jump to A = jump to IF_TRUE label
    //else - means they are not eq - pop the two numers and enter 0 and jump to SP--
    strReturn+="D=0\n";//enter the result to D  
    strReturn+="@SP\nA=M-1\n";//A point to the last value
    strReturn+="A=A-1\n";//A points to the second last value
    strReturn+="M=D\n";//enter to RAM[A] = RAM[second last value]  = D = 0 = false
    //jump to SP--
    strReturn+="@IF_FALSE_1\n";//A = IF_FALSE label
    strReturn+="0;JMP\n";//jump to A

    //IF_TRUE label -pop the two numers and enter 1
    strReturn+="(IF_TRUE_1)\n";
    strReturn+="D=-1\n";//enter the result to D  
    strReturn+="@SP\nA=M-1\n";//A point to the last value
    strReturn+="A=A-1\n";//A points to the second last value
    strReturn+="M=D\n";//enter to RAM[A] = RAM[second last value]  = D = 1 = true

    return strReturn+"(IF_FALSE_1)\n@SP\nM=M-1\n";//SP--
}// end equal
public function lt() returns string
{
    string strReturn="@SP\n";
    strReturn += "A=M-1\n";//A is the address of the top value
    strReturn += "D=M\n";//D is the top value
    strReturn += "A=A-1\n";//A is the address of the first value to compare
    strReturn += "D=D-M\n";//D is the sub between the two top values - if lt - D<0
    strReturn += "@IF_TRUE_2\n";//A is the address of label IF_TRUE_2
    strReturn+="D;JGT\n";//if D<0 jump to A
    //else - pop the two numers , enter 0 and jump to SP--
    strReturn+="D=0\n";//enter the result to D  
    strReturn+="@SP\nA=M-1\n";//A point to the last value
    strReturn+="A=A-1\n";//A points to the second last value
    strReturn+="M=D\n";//enter to RAM[A] = RAM[second last value]  = D = 0 = false
    //jump to SP--
    strReturn+="@IF_FALSE_2\n";//A = IF_FALSE label
    strReturn+="0;JMP\n";//jump to A
    //IF_TRUE_2 label - pop the two numers and enter 1
    strReturn+="(IF_TRUE_2)\n";
    strReturn+="D=-1\n";//enter the result to D  
    strReturn+="@SP\nA=M-1\n";//A point to the last value
    strReturn+="A=A-1\n";//A points to the second last value
    strReturn+="M=D\n";//enter to RAM[A] = RAM[second last value]  = D = 1 = true

    return strReturn+"(IF_FALSE_2)\n@SP\nM=M-1\n";//SP--
}//end lesser than
public function gt() returns string
{
    string strReturn="@SP\n";
    strReturn += "A=M-1\n";//A is the address of the top value
    strReturn += "D=M\n";//D is the top value
    strReturn += "A=A-1\n";//A is the address of the first value to compare
    strReturn += "D=D-M\n";//D is the sub between the two top values - if gt - D>0
    strReturn += "@IF_TRUE_3\n";//A is the address of label IF_TRUE_2
    strReturn+="D;JLT\n";//if D>0 jump to A
    //else - pop the two numers , enter 0 and jump to SP--
    strReturn+="D=0\n";//enter the result to D  
    strReturn+="@SP\nA=M-1\n";//A point to the last value
    strReturn+="A=A-1\n";//A points to the second last value
    strReturn+="M=D\n";//enter to RAM[A] = RAM[second last value]  = D = 0 = false
    //jump to SP--
    strReturn+="@IF_FALSE_3\n";//A = IF_FALSE label
    strReturn+="0;JMP\n";//jump to A
    //IF_TRUE_2 label - pop the two numers and enter 1
    strReturn+="(IF_TRUE_3)\n";
    strReturn+="D=-1\n";//enter the result to D  
    strReturn+="@SP\nA=M-1\n";//A point to the last value
    strReturn+="A=A-1\n";//A points to the second last value
    strReturn+="M=D\n";//enter to RAM[A] = RAM[second last value]  = D = 1 = true 
   
    return strReturn+"(IF_FALSE_3)\n@SP\nM=M-1\n";//SP--
}// end greater than
public function neg() returns string
{
    string strReturn="@SP\n";
    strReturn += "A=M-1\n";//A is the address of the top value
    strReturn+="D=M\n";//D = top value
    strReturn += "M=-D\n";// enter the stack negative D
    return strReturn;
}//end neg
public function not() returns string
{
    string strReturn="@SP\n";
    strReturn += "A=M-1\n";//A is the address of the top value
    strReturn += "M=!M\n";// M is not M
    return strReturn;
}//end not
public function and() returns string
{
     string strReturn="@SP\n";
    strReturn += "A=M-1\n";//A is the address of the top value
    strReturn += "D=M\n";//D= top value of the stack
    strReturn += "A=A-1\n";//A is the address of the second last value of stack
    strReturn += "M=D&M\n";// M is the result of and on the last two values
    return strReturn+"@SP\nM=M-1\n";//SP--
}// end and
public function or() returns string
{
    string strReturn="@SP\n";
    strReturn += "A=M-1\n";//A is the address of the top value
    strReturn += "D=M\n";//D= top value of the stack
    strReturn += "A=A-1\n";//A is the address of the second last value of stack
    strReturn += "M=D|M\n";// M is the result of or on the last two values
    return strReturn+"@SP\nM=M-1\n";//SP--
}// end or

public function label(string line, string nameOfFile) returns string
{
    //for each label - print a label in a format: (fileName.labelName)
    string nameOfLabel = findValueRest(line);
    return "("+nameOfFile+"."+nameOfLabel.substring(0,nameOfLabel.length())+")\n";
}//end label

public function ifgoto(string line, string nameOfFile) returns string
{
 //for each label - print a label in a format: (fileName.labelName)
    string nameOfLabel = findValueRest(line);
    string strReturn="@SP\n";//A=0
    strReturn+="M=M-1\n"; //M=RAM[SP]-1  top of stack
    strReturn+="A=M\n";
    strReturn+="D=M\n";// D is the item in th top of the stack
    strReturn+="@"+nameOfFile+"."+nameOfLabel+"\n";//for some reason the last char in the label is equal to \n
    strReturn+="D;JNE\n";//if the item in the top of stack is not 0 (it's true) jump to the label in A
    return strReturn;
}// end ifgoto

public function goto(string line, string nameOfFile) returns string
{
    string nameOfLabel = findValueRest(line);
    string strReturn = "@"+nameOfFile+"."+nameOfLabel+"\n";//A is the address to jump too
    strReturn+="0;JMP\n";//jump to A
    return  strReturn;
}// end goto

public function functionf(string line, string nameOfFile) returns string
{
    string strReturn="";

    //(name of function)
    string nameOfFunc =findValueRest(line);
    strReturn+="("+nameOfFunc+")\n";
    ///repeat k times - push 0///
    
    //finding the k
    string restLine=line.substring(nameOfFunc.length()+1,line.length());//the rest of the lins without func name
    string kStr =findValueRest(restLine);

    strReturn+="@"+kStr+"\n";//@k
    strReturn+="D=A\n";//D = k
    //@func.End
    strReturn+="@"+nameOfFunc+".End\n";
    strReturn+="D;JEQ\n";//if D=0 means K=0 means num of local args = 0 - no need to enter the loop - jump to end
    //start loop - labal loop
    strReturn+="("+nameOfFunc+".Loop)\n";//(nameOfFunc.Loop)
    strReturn+="@SP\nA=M\nM=0\n";//enter 0 to the stack
    strReturn+="@SP\nM=M+1\n";//SP++
    //load label loop to A
    strReturn+="@"+nameOfFunc+".Loop\n";
    strReturn+="D=D-1;JNE\n";//D-- if D not Zero jump to A - to label loop
    strReturn+="("+nameOfFunc+".End)\n";//label end of loop
    return strReturn;
} //end function

public function returnFunc() returns string
{
    //clear the arguments & other junk from the stack
    //Restore the segments of f
    //Transfer control back to f (jump to the saved return address )
     string strReturn="";
     //FRAME=LCL 
     strReturn+="@LCL\nD=M\n";//D = RAM[LCL] D is temp variable to save the local value
     //RET = *(FRAME-5)
     strReturn+="@5\nA=D-A\n";//A = D-5 A points to the return address in the stack
     strReturn+="D=M\n";//D return address
     strReturn+="@13\nM=D\n";//save ret address to register 13 (temp register) 
    //pop ARG
    strReturn+="@SP\nM=M-1\nA=M\nD=M\n@ARG\nA=M\nM=D\n";//enter to segment ARG the top value in the stack
    //SP=ARG+1
    strReturn+="@ARG\nD=M\n@SP\nM=D+1\n";//SP points to the next free location in arg segment
    //restore That of the caller - THAT = *(FRAME-1)
    strReturn+="@LCL\nM=M-1\nA=M\nD=M\n@THAT\nM=D\n";
    //restore THIS of the caller - THIS = *(FRAME-2)
    strReturn+="@LCL\nM=M-1\nA=M\nD=M\n@THIS\nM=D\n";
    //restore ARG of the caller - ARG = *(FRAME-3)
    strReturn+="@LCL\nM=M-1\nA=M\nD=M\n@ARG\nM=D\n";
    //restore LCL of the caller - LCL = *(FRAME-4)
    strReturn+="@LCL\nM=M-1\nA=M\nD=M\n@LCL\nM=D\n";
    //goto RET
    strReturn+="@13\nA=M\n0;JMP\n";//load the ret address and jump

     return  strReturn;
} // end return

int counter=0;//global counter for labels
public function callFunc(string line) returns string
{
    string strReturn="";
    //push return-address

    string nameOfFunc = findValueRest(line);

    strReturn+="@"+nameOfFunc+".ReturnAddress"+counter.toString()+"\n";
    strReturn+="D=A\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";//saves the return address in the stack and SP++
    //saving all the segments into the stack
    //push local
    strReturn+="@LCL\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
    //push argument
    strReturn+="@ARG\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
    //push THIS
    strReturn+="@THIS\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";
    //push THAT
    strReturn+="@THAT\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n";

    //finding the n
    string restLine=line.substring(nameOfFunc.length()+1,line.length());//the rest of the lins without func name
    string nStr = findValueRest(restLine);
        //convert string k to int for the loop
        int | error nInt = ints:fromString(nStr);  
        if(nInt is int)
         {
            //ARG=SP-n-5
            strReturn+="@SP\nD=M\n";//D=SP
            strReturn+="@"+nInt.toString()+"\n";//@num of args
            strReturn+="D=D-A\n";//D=SP-n
            strReturn+="@5\nD=D-A\n";//D=SP-n-5
            strReturn+="@ARG\nM=D\n";//enter to arg the caller arguments
             
         }
         else
         {
             io:println("error! n is not int");
         }  
    //LCL=SP
    strReturn+="@SP\nD=M\n@LCL\nM=D\n";
    //goto g
    strReturn+="@"+nameOfFunc+"\n0;JMP\n";
    //label return address
    strReturn+="("+nameOfFunc+".ReturnAddress"+counter.toString()+")\n";
    counter=counter+1;
    return strReturn ;
} // end callFunc

public function main() returns @tainted error? 
{//the FileInfo must use error type - so the main func must return error

    string dirName= io:readln("Enter your directory's name:");//שם הספריה עליה עוברים 
    file:FileInfo[]|error readDirFiles=file:readDir(<@untained>  dirName);//רשימה של כל הקבצים בספריה
    string finalASM="";
    int vmCounter=0;
    if(readDirFiles is file:FileInfo[])//if the read file success = is iterable
    {
        string writePath = dirName;
        string strToAsm="";
        foreach var file in readDirFiles 
        {
           // io:println(readDirFiles.);

            if(file.getName().endsWith(".vm"))
                {
                    vmCounter= vmCounter+1;

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
                 foreach var chr in readAllStr {
                     line+=chr;//add chars until the end of the line
                     if(chr=="\n")
                     {
                         arrLines[i] = line; //if its a new line - enter line into the array
                         line = ""; //reset the line
                         i=i+1;                         
                     }
                     
                 }    

                 //for each line:
                 //if its a note - ignore. else - send to the correct function
                 
                 foreach var ln in arrLines {
                     //strToAsm+=ln;
                     if(!ln.startsWith("\\"))
                     {
                         //save the file name without the .vm
                         string fileN=file.getName().substring(0,file.getName().length()-3);
                         
                         if(ln.startsWith("push"))
                         {
                            strToAsm+= push(ln.substring(5, ln.length()),fileN);//send to push the rest of the line
                         }
                         
                         if(ln.startsWith("pop"))
                         {
                            strToAsm+=pop(ln.substring(4, ln.length()),fileN);
                         }
                         if(ln.startsWith("add"))
                         {
                             strToAsm+=add();
                         }
                         if(ln.startsWith("sub"))
                         {
                             strToAsm+=sub();
                         }
                         if(ln.startsWith("eq"))
                         {
                             strToAsm+=eq();
                         }
                         if(ln.startsWith("lt"))
                         {
                             strToAsm+=lt();
                         }
                         if(ln.startsWith("gt"))
                         {
                             strToAsm+=gt();
                         }
                         if(ln.startsWith("neg"))
                         {
                             strToAsm+=neg();
                         }
                         if(ln.startsWith("not"))
                         {
                             strToAsm+=not();
                         }
                         if(ln.startsWith("and"))
                         {
                             strToAsm+=and();
                         }
                         if(ln.startsWith("or"))
                         {
                             strToAsm+=or();
                         }
                         if(ln.startsWith("label"))
                         {
                             strToAsm+=label(ln.substring(6, ln.length()), fileN);
                         }
                         if(ln.startsWith("if-goto"))
                         {
                             strToAsm+=ifgoto(ln.substring(8, ln.length()), fileN);
                         }
                         if(ln.startsWith("goto"))
                         {
                             strToAsm+=goto(ln.substring(5, ln.length()), fileN);
                         }
                         if(ln.startsWith("function"))
                         {
                             strToAsm+=functionf(ln.substring(9, ln.length()), fileN);
                         }
                         if(ln.startsWith("return"))
                         {
                             strToAsm+=returnFunc();
                         }
                         if(ln.startsWith("call"))
                         {
                             strToAsm+=callFunc(ln.substring(5, ln.length()));
                         }
                         
                     }  
                 }
                 
                }//end if

               
                      
        } //end foreach file               

         io:println(vmCounter);
        if(vmCounter>1) //if num pf vm files is more then 1 - we need Bootstrapping 
        {
            // Initialize the SP to 256
            string boostrapp = "@256\nD=A\n@SP\nM=D\n";
            boostrapp+=callFunc("Sys.init 0");
            finalASM+=boostrapp;
        }
                 
        finalASM+=strToAsm;
        writePath = writePath +".asm"; //creat new .asm 
        io:WritableByteChannel writableFileResult= check io:openWritableFile(<@untained>  writePath);
        io:WritableCharacterChannel destinationChannel=new(writableFileResult, "UTF-8");
        var writeToAsm = destinationChannel.write(finalASM, 0);
     
    }//end  if(readDirFiles
    
    
}//end main func
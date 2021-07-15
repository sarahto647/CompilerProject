import ballerina/io;
import ballerina/file;
import ballerina/lang.'int as ints;
//import ballerina/log;


public function push (string line, string nameOfFile) returns string{
    string strReturn = "";
 /////// GROUP 1///////
    //LOCAL
     if( line.startsWith("local"))
    {
        strReturn += "@"+line.substring(6, line.length())+"D=A\n"+"@LCL"+"\nA=M+D\nD=M\n@SP\nA=M\nM=D\n";
    }//end of local
    //ARGUMENT
     if( line.startsWith("argument"))
    {
        strReturn += "@"+line.substring(9, line.length())+"D=A\n"+"@ARG"+"\nA=M+D\nD=M\n@SP\nA=M\nM=D\n";
    }//end of argument
    //THIS
     if( line.startsWith("this"))
    {
        strReturn += "@"+line.substring(5, line.length())+"D=A\n"+"@THIS"+"\nA=M+D\nD=M\n@SP\nA=M\nM=D\n";
    }//end of this
    //THAT
    if( line.startsWith("that"))
    {
        strReturn += "@"+line.substring(5, line.length())+"D=A\n"+"@THAT"+"\nA=M+D\nD=M\n@SP\nA=M\nM=D\n";
    }//end of that
 /////// GROUP 2///////
    if( line.startsWith("temp"))
    {
        strReturn += "@5\n"+"D=A\n"+"@"+line.substring(5, line.length())+"A=D+A\nD=M\n@SP\nA=M\nM=D\n";
    }
 /////// GROUP 3///////
    if(line.startsWith("static"))
     {
         strReturn+="@"+nameOfFile+"."+line.substring(7, line.length())+"D=M\n@SP\nA=M\nM=D\n";//A - save the address of this
     }
 /////// GROUP 4///////
    if( line.startsWith("pointer 0"))
    {
        strReturn+="@THIS\n";//save in A the address of this
        strReturn+="D=M\n";//D save the value in the address
        strReturn+="@SP\n";//A=0
        strReturn+="A=M\n";//A save the next empty
        strReturn+="M=D\n";//push into the stack
    }

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
         strReturn += "@"+line.substring(9, line.length())+"D=A"+"\n"+"@SP\nA=M\nM=D\n";//@value
    }//end of constant
 /////END/////
    return strReturn+"@SP"+"\n"+"M=M+1\n";//SP++
}

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
         int | error x = ints:fromString(line.substring(6, line.length()-2));//-2 to sub the \n
        
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
            io:println("error");
         }
        }//end if local
         
        //ARGUMENT
        if(line.startsWith("argument"))
        {
            int | error x = ints:fromString(line.substring(9, line.length()-2));//-2 to sub the \n
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
             io:println("error");
            }
        }//end if arg

        //THIS
        if(line.startsWith("this"))
        {
            int | error x = ints:fromString(line.substring(5, line.length()-2));//-2 to sub the \n
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
             io:println("error");
            }
        }//end if this

        //THAT
        if(line.startsWith("that"))
        {
            int | error x = ints:fromString(line.substring(5, line.length()-2));//-2 to sub the \n
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
             io:println("error");
            }
        }//end if that

 //////// GROUP 2///////////////////

     //TEMP
     if(line.startsWith("temp"))
      {
          int | error x = ints:fromString(line.substring(5, line.length()-2));//-2 to sub the \n
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
             io:println("error");
            }
        }//end if temp

 //////// GROUP 3///////////////////
    if(line.startsWith("static"))
     {//pop static x - pop the top of the stack into address RAM[className.x ]	All  static variables are saved on RAM[16-255]
         strReturn+="@"+nameOfFile+"."+line.substring(7, line.length());//A - save the address of this
     }
 //////// GROUP 4///////////////////

    if(line.startsWith("pointer 0"))
     {
         strReturn+="@THIS\n";//A - save the address of this
     }

      if(line.startsWith("pointer 1"))
     {
         strReturn+="@THAT\n";//A - save the address of this
     }
 //////// END ///////////////////
    strReturn+="M=D\n";//D is the value to pop - M=D copy the value into memory
    return strReturn+"@SP"+"\n"+"M=M-1\n";//SP--
        
}//end pop func

public function add() returns string
{
    string strReturn="";
    strReturn+="@SP\n";//A=0 - A points to the next empty location in the stack
    strReturn+="A=M-1\n";//A=RAM[A]-1 - A points to the last value in the stack
    strReturn+="D=M\n";//D=RAM[A] - D contains the  last value in the stack
    strReturn += "A=A-1\n";//A points to the second last value
    strReturn +="M=D+M\n";//M contains the sum of the two - and push to the stack
    return strReturn+"@SP\nM=M-1\n";//SP--
}

public function sub() returns string
{
    string strReturn="";
    strReturn+="@SP\n";//A=0 - A points to the next empty location in the stack
    strReturn+="A=M-1\n";//A=RAM[A]-1 - A points to the last value in the stack
    strReturn+="D=M\n";//D=RAM[A] - D contains the  last value in the stack
    strReturn += "A=A-1\n";//A points to the second last value
    strReturn +="M=M-D\n";//M contains the sub of the two - and push to the stack
    return strReturn+"@SP\nM=M-1\n";//SP--
}

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
}
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
}
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
}
public function neg() returns string
{
    string strReturn="@SP\n";
    strReturn += "A=M-1\n";//A is the address of the top value
    strReturn+="D=M\n";//D = top value
    strReturn += "M=-D\n";// enter the stack negative D
    return strReturn;
}
public function not() returns string
{
    string strReturn="@SP\n";
    strReturn += "A=M-1\n";//A is the address of the top value
    strReturn += "M!M\n";// M is not M
    return strReturn;
}
public function and() returns string
{
     string strReturn="@SP\n";
    strReturn += "A=M-1\n";//A is the address of the top value
    strReturn += "D=M\n";//D= top value of the stack
    strReturn += "A=A-1\n";//A is the address of the second last value of stack
    strReturn += "M=D&M\n";// M is the result of and on the last two values
    return strReturn+"@SP\nM=M-1\n";//SP--
}
public function or() returns string
{
    string strReturn="@SP\n";
    strReturn += "A=M-1\n";//A is the address of the top value
    strReturn += "D=M\n";//D= top value of the stack
    strReturn += "A=A-1\n";//A is the address of the second last value of stack
    strReturn += "M=D|M\n";// M is the result of or on the last two values
    return strReturn+"@SP\nM=M-1\n";//SP--
}

public function main() returns @tainted error? 
{//the FileInfo must use error type - so the main func must return error

    string dirName= io:readln("Enter your directory's name:");//שם הספריה עליה עוברים 
    file:FileInfo[]|error readDirFiles=file:readDir(<@untained>  dirName);//רשימה של כל הקבצים בספריה
    if(readDirFiles is file:FileInfo[])//if the read file secces = is iterable
    {
        foreach var file in readDirFiles 
        {
            if(file.getName().endsWith(".vm"))
                {
                    io:println(file.getName());
                    string writePath = file.getPath();
                    writePath = writePath.substring(0, writePath.length()-3);//remove the .vm end
                    writePath = writePath +".asm"; //add the .asm end
                    io:println(writePath);

                   io:ReadableByteChannel readableFieldResult = check io:openReadableFile(file.getPath());
                   io:ReadableCharacterChannel sourceChannel =new(readableFieldResult, "UTF-8");
                
                   io:WritableByteChannel writableFileResult= check io:openWritableFile(writePath);
                   io:WritableCharacterChannel destinationChannel=new(writableFileResult, "UTF-8");

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
                 string strToAsm="";
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

                     }  
                 }
                 var writeToAsm = destinationChannel.write(strToAsm, 0);


                }//end if

                      
        } //end foreach file               
     
    }//end  if(readDirFiles
    
    
}//end main func
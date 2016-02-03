/*
  Blank Simple Project.c
  http://learn.parallax.com/propeller-c-tutorials 
*/
#include "simpletools.h"                      // Include simple tools

int main()                                    // Main function
{
  // Add startup code here.

  int count = 0;
  while(1)
  {
    print("Hello World!");
    print("Repeated: ",count);
    count++;
  }  
}

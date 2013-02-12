#include <iostream>
#include <iterator>
using namespace std;
string static_name;
struct expression
{
  string name;
  expression(void (*f)(expression*,expression**),expression** ps=0, int n=0)
  {
    name = "normal";
    params = new expression*[n];
    for(int m=0;m<n;m++)
    {
      params[m] = ps[m];
    }
    num_of_exp = n;
    funcptr = f;
  }
  
  expression** params;
  int num_of_exp;
  struct {
    double d;
    int i;
    char* str;
    expression* exp;
  } ret;
   void (*funcptr)(expression*,expression**);
  void execute()
  {
    funcptr(this,params);
  }
};
void plus_func(expression* ths, expression** pars)
{
  pars[0]->execute();
  pars[1]->execute();
  ths->ret.d = pars[0]->ret.d + pars[1]->ret.d;
}
void nothing(expression* ths, expression** pars)
{
}
struct getval: public expression
{  
  getval(double x): expression(nothing)
  {   
    name = "getval";
    ret.d = x;
  }
};


void execute_seq(expression* ths, expression** pars)
  {
    if(ths->num_of_exp>0){
	//cout << ths->name << endl;
        pars[0]->execute();
    }
    ths->ret.exp->execute();
   // cout << ":->" << ths->ret.exp->ret.d << endl;   
    ths->ret.d = ths->ret.exp->ret.d;
    
    
   
  }
struct sequence: public expression
{
  
  sequence(expression*exp, sequence * n = 0): expression(execute_seq)
  {
    name = "sequence";
    ret.exp = exp;
    params = new expression*[1];
    if(n)
    {      
      params[0] = n;
      num_of_exp = 1;
    }    
  }
  
  sequence * add(sequence* n)
  {
    n->params[0]= this;    
    n->num_of_exp = 1;
    return n;
  }
  
  
};

vector<expression*> func_table = vector<expression*>();
vector<string> temp_names = vector<string>();

void clean_func_names()
{
  
  for(vector<string>::iterator itr = temp_names.begin();itr!=temp_names.end();itr++)
  {
    for(vector<expression*>::iterator fitr=func_table.begin();fitr!=func_table.end();fitr++)
    {
      if((*fitr)->name == (*itr))
      {
	func_table.erase(fitr);
      }
    }    
  }
}
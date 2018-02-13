/*********************************************
 * OPL 12.5 Model
 * Author: seb
 * Creation Date: 11 févr. 2018 at 15:13:55
 *********************************************/

 int n = ...;
 int m = ...;
 range Rn = 1..n;
 range Rm = 1..m;
 
 int c[Rm][Rn] = ...;
 int a[Rm][Rn] = ...;
 int b[Rm] = ...;
 
 dvar boolean x[Rm][Rn];
 
 minimize sum(i in Rn, j in Rm) (c[j][i] * x[j][i]);
 
 subject to{
   forall(i in Rn){
   		const1: sum(j in Rm)(x[j][i]) == 1;
   }
   forall(j in Rm){
   		const2: sum(i in Rn)(a[j][i]) <= b[j];  
   }
 }
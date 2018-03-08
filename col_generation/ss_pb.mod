/*********************************************
 * OPL 12.5 Model
 * Author: seb
 * Creation Date: 17 févr. 2018 at 14:00:46
 *********************************************/

int n = ...;
int m = ...;
range Rn = 1..n;
range Rm = 1..m;

int c[Rm][Rn] = ...;
int a[Rm][Rn] = ...;
int b[Rm] = ...;

float u[Rn] = ...;
float v[Rm] = ...;

dvar boolean x[Rm][Rn];


minimize
  sum(j in Rm) (sum(i in Rn) ((c[j][i] - u[i])* x[j][i]) - v[j]);
subject to {
  forall( j in Rm )
	  ctFill:
	    sum(i in Rn) a[j][i] * x[j][i] <= b[j];
}
 
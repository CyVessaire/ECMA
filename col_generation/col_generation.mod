/*********************************************
 * OPL 12.5 Model
 * Author: seb
 * Creation Date: 17 févr. 2018 at 14:00:06
 *********************************************/

// Données du problème
int n = ...;
int m = ...;
range Rn = 1..n;
range Rm = 1..m;

int c[Rm][Rn] = ...;
int a[Rm][Rn] = ...;
int b[Rm] = ...;
 

// Pattern of roll cutting that are generated.
// Some simple default pattern are given initially in cutstock.dat
tuple s {
   key int id;
   int machine;
   int cost;
   int fill[Rn];
}

{s} Patterns = ...;

// valeurs duales du problème.
float u[Rn] = ...;
float v[Rm] = ...;


// How many of each pattern is to be cut
dvar float+ Cut[Patterns] in 0..1;

// Minimize cost : here each pattern as the same constant cost so that
// we minimize the number of rolls used.     
minimize
  sum(p in Patterns) 
    p.cost * Cut[p];

subject to {
  // Unique constraint in the master model is to cover the item demand.
  forall( i in Rn ) 
    ctTache:
      sum(p in Patterns) 
        p.fill[i] * Cut[p] == 1;
  forall( j in Rm ) 
    ctMach:
      sum(p in Patterns: p.machine == j) 
        Cut[p] <= 1;
}

tuple r {
   int machine;
   int cost;
   float cut;
   int aff[Rn];
};

{r} Result = {<p.machine, p.cost ,Cut[p], p.fill> | p in Patterns : Cut[p] > 1e-3};
// set dual values used to fill in the sub model.
execute FillDuals {
  for(var i in Rn) {
     u[i] = ctTache[i].dual;
  }
  for(var j in Rm) {
     v[j] = ctMach[j].dual;
  }
}

// Output the current result
execute DISPLAY_RESULT {
   // writeln(u)
   // writeln(v)
   writeln(Result);
}

main {
   var status = 0;
   thisOplModel.generate();
   // This is an epsilon value to check if reduced cost is strictly negative
   var RC_EPS = 1.0e-6;
   
   // Retrieving model definition, engine and data elements from this OPL model
   // to reuse them later
   var masterDef = thisOplModel.modelDefinition;
   var masterCplex = cplex;
   var masterData = thisOplModel.dataElements;   
   
   // Creating the master-model
   var masterOpl = new IloOplModel(masterDef, masterCplex);
   masterOpl.addDataSource(masterData);
   masterOpl.generate();
   
   // Preparing sub-model source, definition and engine
   var subSource = new IloOplModelSource("ss_pb.mod");
   var subDef = new IloOplModelDefinition(subSource);
   var subCplex = new IloCplex();
   
   var best;
   var curr = Infinity;
   var Rm = masterOpl.Rm;
   var Rn = masterOpl.Rn;
   var c = masterOpl.c;
	
	
   var itt = 0
   while ( itt != 1000 ) {
      itt += 1
      best = curr;
      writeln("Solve master.");
      if ( masterCplex.solve() ) {
        masterOpl.postProcess();
        curr = masterCplex.getObjValue();
        writeln();
        writeln("MASTER OBJECTIVE: ",curr);
      } else {
         writeln("No solution to master problem!");
         masterOpl.end();
         break;
      }
      // Ceating the sub model
      var subOpl = new IloOplModel(subDef,subCplex);
      
      // Using data elements from the master model.
      var subData = new IloOplDataElements();
      subData.n = masterOpl.n;
      subData.m = masterOpl.m;
      subData.a = masterOpl.a;
      subData.b = masterOpl.b;
      subData.c = masterOpl.c;
      subData.u = masterOpl.u;
      subData.v = masterOpl.v;  
      subOpl.addDataSource(subData); 
      subOpl.generate();
      
      // Previous master model is not needed anymore.
      masterOpl.end();
      
      writeln("Solve sub.");
      if ( subCplex.solve() &&
           subCplex.getObjValue() <= -RC_EPS) {
        writeln();
        writeln("SUB OBJECTIVE: ",subCplex.getObjValue());
      } else {
        writeln("No new good pattern, stop.");
           subData.end();
        subOpl.end();         
        break;
      }
      // prepare next iteration
      var solution_current = subOpl.x.solutionValue
      //write(solution_current);
      for (var mach in Rm) {
        var cout = 0
        for (var tache in Rn){
          cout += solution_current[mach][tache]*c[mach][tache]
          }
      	masterData.Patterns.add(masterData.Patterns.size,mach,cout,solution_current[mach]);
      }      	
      // writeln(masterData.Patterns);
      masterOpl = new IloOplModel(masterDef,masterCplex);
      masterOpl.addDataSource(masterData);
      masterOpl.generate();
      // End sub model
         subData.end();
      subOpl.end();      
   }

   subDef.end();
   subCplex.end();
   subSource.end();
   
   status;
}
 
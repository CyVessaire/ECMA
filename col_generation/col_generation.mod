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
   int cost;
   int fill[Rn];
}

{s} Patterns[Rm] = ...;

// valeurs duales du problème.
float u[Rn] = ...;
float v[Rm] = ...;


// How many of each pattern is to be cut
dvar float+ Cut[j in Rm][Patterns[j]] in 0..1;
     
// Minimize cost : here each pattern as the same constant cost so that
// we minimize the number of rolls used.     
minimize
  sum( j in Rm , p in Patterns[j]) 
    p.cost * Cut[j][p];

subject to {
  // Unique constraint in the master model is to cover the item demand.
  forall( i in Rn ) 
    ctTache:
      sum(j in Rm, p in Patterns[j] ) 
        p.fill[i] * Cut[j][p] == 1;
  forall( j in Rm ) 
    ctMach:
      sum( p in Patterns[j], i in Rn) 
        p.fill[i] * Cut[j][p] <= 1;
}

tuple r {
   int machine;
   s p;
   float cut;
};

{r} Result = {<j, p ,Cut[j][p]> | j in Rm, p in Patterns[j] : Cut[j][p] > 1e-3};
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

   while ( best != curr ) {
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
      subData.RollWidth = masterOpl.RollWidth;
      subData.Size = masterOpl.Size;
      subData.Duals = masterOpl.Duals;     
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
      masterData.Patterns.add(masterData.Patterns.size,1,subOpl.Use.solutionValue);
      masterOpl = new IloOplModel(masterDef,masterCplex);
      masterOpl.addDataSource(masterData);
      masterOpl.generate();
      // End sub model
         subData.end();
      subOpl.end();      
   }
    
   // Check solution value
   if (Math.abs(curr - 46.25)>=0.0001) {
      status = -1;
      writeln("Unexpected objective value");
   }         

   subDef.end();
   subCplex.end();
   subSource.end();
   
   status;
}
 
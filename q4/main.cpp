#include <ilcplex/ilocplex.h>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
#include <string>
#include <cstring>
#include <ctime>
#include <cstdio>
#include <iostream>

ILOSTLBEGIN
using namespace std;

typedef IloArray<IloNumVarArray> NumVarMatrix;
typedef IloArray<NumVarMatrix>   NumVar3Matrix;

typedef std::pair<int,float> mypair;

bool pairCompare(const std::pair<int, float>& firstElem, const std::pair<int, float>& secondElem) 
{
  return firstElem.second <= secondElem.second;
}

typedef pair<vector<vector<float> >, vector<int>> mysecondpair;

class data{
public:
	int n; int m;
	vector<int> b;
	vector<vector<int> > a;
	vector<vector<int> > c;
};

string name_files(int i)
{
	switch(i)
	{
		case 1:
		{
			return "GAP-a05100.dat";
		}
		case 2:
		{
			return "GAP-a05200.dat";
		}
		case 3:
		{
			return "GAP-a10100.dat";
		}
		case 4:
		{
			return "GAP-a10200.dat";
		}
		case 5:
		{
			return "GAP-a20100.dat";
		}
		case 6:
		{
			return "GAP-a20200.dat";
		}
		case 7:
		{
			return "GAP-b05100.dat";
		}
		case 8:
		{	
			return "GAP-b05200.dat";
		}
		case 9:
		{
			return "GAP-b10100.dat";
		}
		case 10:
		{
			return "GAP-b10200.dat";
		}
		case 11:
		{
			return "GAP-b20100.dat";
		} 
		case 12: 
		{
			return "GAP-b20200.dat";
		} 
		case 13: 
		{
			return "GAP-c05100.dat";
		} 
		case 14: 
		{
			return "GAP-c05200.dat";
		} 
		case 15: 
		{
			return "GAP-c10100.dat";
		} 
		case 16: 
		{
			return "GAP-c10200.dat";
		} 
		case 17: 
		{
			return "GAP-c10400.dat";
		} 
		case 18: 
		{
			return "GAP-c15900.dat";
		}
		case 19: 
		{ 
			return "GAP-c20100.dat";
		} 
		case 20: 
		{ 
			return "GAP-c20200.dat";
		} 
		case 21: 
		{ 
			return "GAP-c20400.dat";
		} 
		case 22: 
		{ 
			return "GAP-c201600.dat";
		} 
		case 23: 
		{ 
			return "GAP-c30900.dat";
		} 
		case 24: 
		{ 
			return "GAP-c40400.dat";
		} 
		case 25: 
		{ 
			return "GAP-c401600.dat";
		} 
		case 26: 
		{ 
			return "GAP-c60900.dat";
		} 
		case 27: 
		{ 
			return "GAP-c801600.dat";
		} 
		case 28: 
		{ 
			return "GAP-d05100.dat";
		} 
		case 29: 
		{ 
			return "GAP-d05200.dat";
		} 
		case 30: 
		{ 
			return "GAP-d10100.dat";
		} 
		case 31: 
		{ 
			return "GAP-d10200.dat";
		} 
		case 32: 
		{ 
			return "GAP-d10400.dat";
		} 
		case 33: 
		{ 
			return "GAP-d15900.dat";
		} 
		case 34: 
		{ 
			return "GAP-d20100.dat";
		} 
		case 35: 
		{ 
			return "GAP-d20200.dat";
		} 
		case 36: 
		{ 
			return "GAP-d20400.dat";
		} 
		case 37: 
		{ 
			return "GAP-d201600.dat";
		} 
		case 38: 
		{ 
			return "GAP-d30900.dat";
		} 
		case 39: 
		{ 
			return "GAP-d40400.dat";
		} 
		case 40: 
		{ 
			return "GAP-d401600.dat";
		} 
		case 41: 
		{ 
			return "GAP-d60900.dat";
		} 
		case 42: 
		{ 
			return "GAP-d80160.dat";
		}
	}
}

data getData(char nom_fichier[])
{
	int n, m;
	vector<int> b, a, c;
	bool inC, inA = false;

	ifstream fichier(nom_fichier);
	if (fichier)
	{
		int count = 0;
		for( std::string line; getline( fichier, line ); )
		{
			if (line[0] == 'n')
			{
				string nstr;
				for ( int i = 0 ; i < line.length(); i++)
				{
					if (isdigit(line[i]))
					{
						nstr += line[i];
					}
				}
				n = stoi(nstr);
			}
			else if (line[0] == 'm')
			{
				string mstr;
				for ( int i = 0 ; i < line.length(); i++)
				{
					if (isdigit(line[i])){
						mstr += line[i];
					}
				}
				m = stoi(mstr);
			}
			else if (line[0] == 'c')
			{
				inC = true;
			}
			else if (line[0] == 'a')
			{
				inA = true; inC = false;
			}
			else if (line[0] == 'b')
			{
				inA = false;
				string bstr; bool started = false;
				for ( int i = 0 ; i < line.length(); i++)
				{
					if (isdigit(line[i]))
					{
						bstr += line[i]; started = true;
					}
					else if (started)
					{
						b.push_back(stoi(bstr));
						bstr = ""; started = false;
					}
				}
			}
			else{
				vector<int> nb;
				string nbstr; bool started = false;
				for ( int i = 0 ; i < line.length(); i++)
				{
					if (isdigit(line[i]))
					{
						nbstr += line[i]; started = true;
					}
					if (started && (!isdigit(line[i]) || (isdigit(line[i]) && i == line.length() - 1)))
					{
						nb.push_back(stoi(nbstr));
						nbstr = ""; started = false;
					}
				}
				if (inA)
				{
					a.insert(a.end(), nb.begin(), nb.end());
				}
				if (inC)
				{
					c.insert(c.end(), nb.begin(), nb.end());
				}
			}
			
		}
	//Add to cplex environment
		vector<vector<int> > cdat, adat;
		vector<int> custom;
		for (int i = 0; i < n; i++)
		{
			custom.push_back(0);
		}
		for (int j = 0; j < m; j++)
		{
			adat.push_back(custom);
			cdat.push_back(custom);
		}
		int j, igiven = 0;
		for (int i = 0; i < a.size(); i++)
		{
			j = i/n;
			igiven = i%n;
			adat[j][igiven] = a[i];
			cdat[j][igiven] = c[i];
		}
	data D;
	D.a = adat;
	D.b = b;
	D.c = cdat;
	D.n = n;
	D.m = m;
	cout << "data exported" << endl;
	fichier.close();
	return D;
	}
	data D;
	cout << "issue in reading data, empty reading" << endl;
	return D;
}


int main() 
{
	cout << "Which file?" << endl;
	for(int i=1; i<43; i++)
	{
		cout << "file: " << i << " , " << name_files(i) << endl;
	}
	cout << "Which file? please insert number" << endl;
	int filenumber;
	cin >> filenumber;
	if(filenumber > 42)
	{
		cout << "error, wrong number" << endl;
		return 0;
	}
	if(filenumber < 0)
	{
		cout << "error, wrong number" << endl;
		return 0;
	}
	cout << "loading file: " << name_files(filenumber) << endl;

	char *sfile;
	sfile = new char[name_files(filenumber).size() + 1];
    memcpy(sfile, name_files(filenumber).c_str(), name_files(filenumber).size() + 1);

	data d = getData(sfile);
	
	cout << d.n << " " << d.m << endl;

	clock_t time = clock();
	/*****SOLVE FIRST TIME**************/
	//************DEFINE MODEL************//
	//Define environment
	IloEnv env;
	IloModel model(env);
	IloCplex cplex(env);
	cplex.extract(model);
	//initialize variables and objective
	IloExpr obj(env);

	NumVarMatrix x(env,d.m);
	for(int j=0; j< d.m; j++) 
	{
        x[j] = IloNumVarArray(env, d.n);
		for(int i=0; i<d.n; i++) 
		{
			x[j][i] = IloNumVar(env, 0.0, 1.0, ILOFLOAT);
			obj += d.c[j][i]*x[j][i];
		}
	}
	//add objective
	model.add(IloMinimize(env, obj));
	// destroy objective
	obj.end();
	//add constraints
	for (int i = 0; i < d.n; i++)
	{
		IloExpr sc(env);
		for (int j = 0; j < d.m; j++)
		{
			sc += x[j][i];
		}
		// added constraint \sum_i x[i] == 1 , i.e. the production constraint
		model.add(sc == 1);
		sc.end();
	}
	//Get capacities
	IloExprArray capacity(env, d.m);
	for (int j = 0; j < d.m; j++)
	{
		capacity[j] = IloExpr(env);
		for (int i = 0; i < d.n; i++)
		{
			capacity[j] += d.a[j][i] * x[j][i];
		}
		// added constraint capacity
		// model.add(capacity[j] <= d.b[j]);
		// we will actually add cut, here is the relaxed problem without this constraint, thus we don't add the capacity constraint.
	}
	
	//solve
	cplex.exportModel("ex2.lp");
	cplex.solve();
	cout << "OBJECTIVE : " << cplex.getObjValue() << endl;
	for (int j = 0; j < d.m; j++)
	{
		cout << "machine " << j << " : ";
		for (int i = 0; i < d.n; i++)
		{
			cout << cplex.getValue(x[j][i]) << " ";
		}
		cout << " : capacity " << cplex.getValue(capacity[j]) << " vs " << d.b[j];
		cout << endl;
	}
	//Set verbosity to none
	cplex.setOut(env.getNullStream());

	//Export data to xstar and to capacitystar
	vector<vector<float> > xstar;
	vector<int> capacitystar;
	for (int j = 0; j < d.m; j++)
	{
		capacitystar.push_back(cplex.getValue(capacity[j]));
		vector<float> store;
		for (int i = 0; i < d.n; i++)
		{
			store.push_back(cplex.getValue(x[j][i]));
		}
		xstar.push_back(store);
	}

	//Initialize and create var for loop
	bool loop = true; bool notviolated = true;
	vector<float> store; 
	vector<int> Cj; 
	vector<mypair > tosort;
	int capa = 0; int idxmax = 0; int max = 0; int size = 0; float v = 0; int count = 0;
	int k0 = 0; vector<float> alpha; int value = 0; vector<int> Nj;

	// start loop
	while (loop){
		//Add cuts
		notviolated = true;
		for (int j = 0; j < d.m; j++)
		{
			if (capacitystar[j] > d.b[j] )
			{
				notviolated = false;
				Cj.clear(); tosort.clear();
				for (int i = 0; i < d.n; i++)
				{
					tosort.push_back(mypair(i, (1 - xstar[j][i])/d.a[j][i]));
				}

				sort(tosort.begin(), tosort.end(), pairCompare);
				capa = d.b[j]; 
				idxmax = 0; 
				max = d.a[j][0];

				// sort the list
				for (int k = 0; k < d.n; k++)
				{
					if (capa - d.a[j][tosort[k].first] >= 0)
					{
						Cj.push_back(tosort[k].first);
						capa -= d.a[j][tosort[k].first];
						if (d.a[j][tosort[k].first] > max)
						{
							idxmax = tosort[k].first;
							max = d.a[j][tosort[k].first];
						}
					}
					else
					{
						Cj.push_back(tosort[k].first);
						k0 = k + 1;
						break;
					}
				}

				//Add reinforcement for lifted cover cuts
				if (k0 < d.n)
				{
					alpha.clear();
					capa = d.b[j];
					for (int t = k0; t < d.n; t++)
					{
						IloEnv envsep;
						IloModel modelsep(envsep);
						IloCplex cplexsep(envsep);
						cplexsep.extract(modelsep);

						//Set verbosity to none
						cplexsep.setOut(env.getNullStream());
						IloNumVarArray xbis(envsep, d.n);
						for (int k = 0; k < d.n; k++)
						{ 
							xbis[k] = IloNumVar(envsep, 0.0, 1.0, ILOINT);
						}
						IloExpr obj(envsep);
						IloExpr cap(envsep);

						for (int k = 0; k < Cj.size(); k++)
						{
							obj += xbis[Cj[k]];
							cap += d.a[j][Cj[k]] * xbis[Cj[k]];
						}
						for (int k = k0; k < alpha.size(); k++)
						{
							obj += alpha[k-k0]*xbis[k];
							cap += d.a[j][k]*xbis[k];
						}

						modelsep.add(IloMaximize(envsep, obj));
						modelsep.add(cap <= d.b[j] - d.a[j][k0]);
						cplexsep.solve();
						if (Cj.size() - 1 - cplexsep.getObjValue() >= 0)
						{
							alpha.push_back(Cj.size() - 1 - cplexsep.getObjValue());
						}
						else
						{
							alpha.push_back(0);
						}
						envsep.end();
					}
				}

				//add expression to model
				IloExpr expr(env);
				for (int k = 0; k < Cj.size(); k++)
				{
					expr += x[j][Cj[k]];
				}
				for (int k = 0; k < alpha.size(); k++)
				{
					expr += alpha[k] * x[j][k0 + k];
				}
				size = Cj.size() - 1;
				model.add(expr <= size);
				expr.end();
			}
		}
		
		if (notviolated) // mean that no constraint was violated
		{
			loop = false; break; // end the loop: we have a solution
		}
		//cplex.exportModel("ex2.lp");
		cplex.solve();
		if (abs(v - cplex.getObjValue()) < 0.01)
		{ 
			count ++; 
		}
		else
		{ 
			count = 0; v = cplex.getObjValue(); 
		};

		if (count >= 100)
		{ 
			break; //no amelioration for 100 iter: stop
		}

		// update the value for the new solution
		cout << "OBJECTIVE : " << cplex.getObjValue() << endl;
		xstar.clear();
		capacitystar.clear();
		store.clear();
		for (int j = 0; j < d.m; j++)
		{
			capacitystar.push_back(cplex.getValue(capacity[j]));
			store.clear();
			for (int i = 0; i < d.n; i++)
			{
				store.push_back(cplex.getValue(x[j][i]));
			}
			xstar.push_back(store);
		}
	}
	/*
	//Relaxation of integrity of constraints
	for (int j = 0; j < d.m; j++)
	{
		model.add(IloConversion(env, x[j], ILOINT));
	}*/

	//Add capacity constraint
	for (int j = 0; j < d.m; j++)
	{
		model.add(capacity[j] <= d.b[j]);
	}
	//solve
	cout << "SOLVING INTEGER PROBLEM NOW" << endl;
	cplex.exportModel("ex2.lp");
	int t = time;
	t = clock() - t;
	cout << (float) t/ CLOCKS_PER_SEC << endl;
	if (600 - (float) t/CLOCKS_PER_SEC > 60)
	{
		cplex.setParam(IloCplex::TiLim, 600 - (float) t/ CLOCKS_PER_SEC);
	}
	else
	{
		cplex.setParam(IloCplex::TiLim, 60);
	}
	if (cplex.solve())
	{
		time = clock() - time;
		cout << (float) time/CLOCKS_PER_SEC << endl;
		cout << "OBJECTIVE : " << cplex.getObjValue() << endl;
		for (int j = 0; j < d.m; j++)
		{
			cout << "machine " << j << " : ";
			for (int i = 0; i < d.n; i++)
			{
				cout << cplex.getValue(x[j][i]) << " ";
			}
			cout << " : capacity " << cplex.getValue(capacity[j]) << " vs " << d.b[j];
			cout << endl;
		}
	}
	else
	{
		cout << "issue here" << endl;
	}

	env.end();
	system("pause");
 	return 0;
}
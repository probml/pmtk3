
int getMaxState(int *nStates,int nNodes)
{
   int n, maxState=0;
   
   for(n = 0; n < nNodes; n++)
   {
      if(nStates[n] > maxState)
         maxState = nStates[n];
   }
   return maxState;
}

void decrementEdgeEnds(int* edgeEnds,int nEdges)
{
   int e;
   for(e = 0; e < nEdges; e++)
   {
      edgeEnds[e]--;
      edgeEnds[e+nEdges]--;
   }
}

void decrementVector(int* vector, int nElements)
{
    int v;
    for(v = 0; v < nElements; v++)
        vector[v]--;
}

double absDif(double a, double b)
 {
     if (a > b)
     {
         return a-b;
     }
     else
     {
         return b-a;
     }
 }
 
 
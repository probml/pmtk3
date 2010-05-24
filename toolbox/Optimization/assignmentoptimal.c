/*
function [assignment, cost] = assignmentoptimal(distMatrix)
*/

#include <mex.h>
#include <matrix.h>

#define CHECK_FOR_INF
#define ONE_INDEXING

void assignmentoptimal(double *assignment, double *cost, double *distMatrix, int nOfRows, int nOfColumns);
void buildassignmentvector(double *assignment, bool *starMatrix, int nOfRows, int nOfColumns);
void computeassignmentcost(double *assignment, double *cost, double *distMatrix, int nOfRows);
void step2a(double *assignment, double *distMatrix, bool *starMatrix, bool *newStarMatrix, bool *primeMatrix, bool *coveredColumns, bool *coveredRows, int nOfRows, int nOfColumns, int minDim);
void step2b(double *assignment, double *distMatrix, bool *starMatrix, bool *newStarMatrix, bool *primeMatrix, bool *coveredColumns, bool *coveredRows, int nOfRows, int nOfColumns, int minDim);
void step3 (double *assignment, double *distMatrix, bool *starMatrix, bool *newStarMatrix, bool *primeMatrix, bool *coveredColumns, bool *coveredRows, int nOfRows, int nOfColumns, int minDim);
void step4 (double *assignment, double *distMatrix, bool *starMatrix, bool *newStarMatrix, bool *primeMatrix, bool *coveredColumns, bool *coveredRows, int nOfRows, int nOfColumns, int minDim, int row, int col);
void step5 (double *assignment, double *distMatrix, bool *starMatrix, bool *newStarMatrix, bool *primeMatrix, bool *coveredColumns, bool *coveredRows, int nOfRows, int nOfColumns, int minDim);

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
	double *assignment, *cost, *distMatrix;
	int nOfRows, nOfColumns;
	
	/* Input arguments */
	nOfRows    = mxGetM(prhs[0]);
	nOfColumns = mxGetN(prhs[0]);
	distMatrix = mxGetPr(prhs[0]);
	
	/* Output arguments */
	plhs[0]    = mxCreateDoubleMatrix(nOfRows, 1, mxREAL);
	plhs[1]    = mxCreateDoubleScalar(0);
	assignment = mxGetPr(plhs[0]);
	cost       = mxGetPr(plhs[1]);
	
	/* Call C-function */
	assignmentoptimal(assignment, cost, distMatrix, nOfRows, nOfColumns);	
}

void assignmentoptimal(double *assignment, double *cost, double *distMatrixIn, int nOfRows, int nOfColumns)
{
	double *distMatrix, *distMatrixTemp, *distMatrixEnd, *columnEnd, value, minValue;
	bool *coveredColumns, *coveredRows, *starMatrix, *newStarMatrix, *primeMatrix;
	int nOfElements, minDim, row, col;
#ifdef CHECK_FOR_INF
	bool infiniteValueFound;
	double maxFiniteValue, infValue;
#endif
	
	/* initialization */
	*cost = 0;
	for(row=0; row<nOfRows; row++)
#ifdef ONE_INDEXING
		assignment[row] =  0.0;
#else
		assignment[row] = -1.0;
#endif
	
	/* generate working copy of distance Matrix */
	/* check if all matrix elements are positive */
	nOfElements   = nOfRows * nOfColumns;
	distMatrix    = (double *)mxMalloc(nOfElements * sizeof(double));
	distMatrixEnd = distMatrix + nOfElements;
	for(row=0; row<nOfElements; row++)
	{
		value = distMatrixIn[row];
		if(mxIsFinite(value) && (value < 0))
			mexErrMsgTxt("All matrix elements have to be non-negative.");
		distMatrix[row] = value;
	}

#ifdef CHECK_FOR_INF
	/* check for infinite values */
	maxFiniteValue     = -1;
	infiniteValueFound = false;
	
	distMatrixTemp = distMatrix;
	while(distMatrixTemp < distMatrixEnd)
	{
		value = *distMatrixTemp++;
		if(mxIsFinite(value))
		{
			if(value > maxFiniteValue)
				maxFiniteValue = value;
		}
		else
			infiniteValueFound = true;
	}
	if(infiniteValueFound)
	{
		if(maxFiniteValue == -1) /* all elements are infinite */
			return;
		
		/* set all infinite elements to big finite value */
		if(maxFiniteValue > 0)
			infValue = 10 * maxFiniteValue * nOfElements;
		else
			infValue = 10;
		distMatrixTemp = distMatrix;
		while(distMatrixTemp < distMatrixEnd)
			if(mxIsInf(*distMatrixTemp++))
				*(distMatrixTemp-1) = infValue;
	}
#endif
				
	/* memory allocation */
	coveredColumns = (bool *)mxCalloc(nOfColumns,  sizeof(bool));
	coveredRows    = (bool *)mxCalloc(nOfRows,     sizeof(bool));
	starMatrix     = (bool *)mxCalloc(nOfElements, sizeof(bool));
	primeMatrix    = (bool *)mxCalloc(nOfElements, sizeof(bool));
	newStarMatrix  = (bool *)mxCalloc(nOfElements, sizeof(bool)); /* used in step4 */

	/* preliminary steps */
	if(nOfRows <= nOfColumns)
	{
		minDim = nOfRows;
		
		for(row=0; row<nOfRows; row++)
		{
			/* find the smallest element in the row */
			distMatrixTemp = distMatrix + row;
			minValue = *distMatrixTemp;
			distMatrixTemp += nOfRows;			
			while(distMatrixTemp < distMatrixEnd)
			{
				value = *distMatrixTemp;
				if(value < minValue)
					minValue = value;
				distMatrixTemp += nOfRows;
			}
			
			/* subtract the smallest element from each element of the row */
			distMatrixTemp = distMatrix + row;
			while(distMatrixTemp < distMatrixEnd)
			{
				*distMatrixTemp -= minValue;
				distMatrixTemp += nOfRows;
			}
		}
		
		/* Steps 1 and 2a */
		for(row=0; row<nOfRows; row++)
			for(col=0; col<nOfColumns; col++)
				if(distMatrix[row + nOfRows*col] == 0)
					if(!coveredColumns[col])
					{
						starMatrix[row + nOfRows*col] = true;
						coveredColumns[col]           = true;
						break;
					}
	}
	else /* if(nOfRows > nOfColumns) */
	{
		minDim = nOfColumns;
		
		for(col=0; col<nOfColumns; col++)
		{
			/* find the smallest element in the column */
			distMatrixTemp = distMatrix     + nOfRows*col;
			columnEnd      = distMatrixTemp + nOfRows;
			
			minValue = *distMatrixTemp++;			
			while(distMatrixTemp < columnEnd)
			{
				value = *distMatrixTemp++;
				if(value < minValue)
					minValue = value;
			}
			
			/* subtract the smallest element from each element of the column */
			distMatrixTemp = distMatrix + nOfRows*col;
			while(distMatrixTemp < columnEnd)
				*distMatrixTemp++ -= minValue;
		}
		
		/* Steps 1 and 2a */
		for(col=0; col<nOfColumns; col++)
			for(row=0; row<nOfRows; row++)
				if(distMatrix[row + nOfRows*col] == 0)
					if(!coveredRows[row])
					{
						starMatrix[row + nOfRows*col] = true;
						coveredColumns[col]           = true;
						coveredRows[row]              = true;
						break;
					}
		for(row=0; row<nOfRows; row++)
			coveredRows[row] = false;
		
	}	
	
	/* move to step 2b */
	step2b(assignment, distMatrix, starMatrix, newStarMatrix, primeMatrix, coveredColumns, coveredRows, nOfRows, nOfColumns, minDim);

	/* compute cost and remove invalid assignments */
	computeassignmentcost(assignment, cost, distMatrixIn, nOfRows);
	
	/* free allocated memory */
	mxFree(distMatrix);
	mxFree(coveredColumns);
	mxFree(coveredRows);
	mxFree(starMatrix);
	mxFree(primeMatrix);
	mxFree(newStarMatrix);

	return;
}

/********************************************************/
void buildassignmentvector(double *assignment, bool *starMatrix, int nOfRows, int nOfColumns)
{
	int row, col;
	
	for(row=0; row<nOfRows; row++)
		for(col=0; col<nOfColumns; col++)
			if(starMatrix[row + nOfRows*col])
			{
#ifdef ONE_INDEXING
				assignment[row] = col + 1; /* MATLAB-Indexing */
#else
				assignment[row] = col;
#endif
				break;
			}
}

/********************************************************/
void computeassignmentcost(double *assignment, double *cost, double *distMatrix, int nOfRows)
{
	int row, col;
#ifdef CHECK_FOR_INF
	double value;
#endif
	
	for(row=0; row<nOfRows; row++)
	{
#ifdef ONE_INDEXING
		col = assignment[row]-1; /* MATLAB-Indexing */
#else
		col = assignment[row];
#endif

		if(col >= 0)
		{
#ifdef CHECK_FOR_INF
			value = distMatrix[row + nOfRows*col];
			if(mxIsFinite(value))
				*cost += value;
			else
#ifdef ONE_INDEXING
				assignment[row] =  0.0;
#else
				assignment[row] = -1.0;
#endif

#else
			*cost += distMatrix[row + nOfRows*col];
#endif
		}
	}
}

/********************************************************/
void step2a(double *assignment, double *distMatrix, bool *starMatrix, bool *newStarMatrix, bool *primeMatrix, bool *coveredColumns, bool *coveredRows, int nOfRows, int nOfColumns, int minDim)
{
	bool *starMatrixTemp, *columnEnd;
	int col;
	
	/* cover every column containing a starred zero */
	for(col=0; col<nOfColumns; col++)
	{
		starMatrixTemp = starMatrix     + nOfRows*col;
		columnEnd      = starMatrixTemp + nOfRows;
		while(starMatrixTemp < columnEnd){
			if(*starMatrixTemp++)
			{
				coveredColumns[col] = true;
				break;
			}
		}	
	}

	/* move to step 3 */
	step2b(assignment, distMatrix, starMatrix, newStarMatrix, primeMatrix, coveredColumns, coveredRows, nOfRows, nOfColumns, minDim);
}

/********************************************************/
void step2b(double *assignment, double *distMatrix, bool *starMatrix, bool *newStarMatrix, bool *primeMatrix, bool *coveredColumns, bool *coveredRows, int nOfRows, int nOfColumns, int minDim)
{
	int col, nOfCoveredColumns;
	
	/* count covered columns */
	nOfCoveredColumns = 0;
	for(col=0; col<nOfColumns; col++)
		if(coveredColumns[col])
			nOfCoveredColumns++;
			
	if(nOfCoveredColumns == minDim)
	{
		/* algorithm finished */
		buildassignmentvector(assignment, starMatrix, nOfRows, nOfColumns);
	}
	else
	{
		/* move to step 3 */
		step3(assignment, distMatrix, starMatrix, newStarMatrix, primeMatrix, coveredColumns, coveredRows, nOfRows, nOfColumns, minDim);
	}
	
}

/********************************************************/
void step3(double *assignment, double *distMatrix, bool *starMatrix, bool *newStarMatrix, bool *primeMatrix, bool *coveredColumns, bool *coveredRows, int nOfRows, int nOfColumns, int minDim)
{
	bool zerosFound;
	int row, col, starCol;

	zerosFound = true;
	while(zerosFound)
	{
		zerosFound = false;		
		for(col=0; col<nOfColumns; col++)
			if(!coveredColumns[col])
				for(row=0; row<nOfRows; row++)
					if((!coveredRows[row]) && (distMatrix[row + nOfRows*col] == 0))
					{
						/* prime zero */
						primeMatrix[row + nOfRows*col] = true;
						
						/* find starred zero in current row */
						for(starCol=0; starCol<nOfColumns; starCol++)
							if(starMatrix[row + nOfRows*starCol])
								break;
						
						if(starCol == nOfColumns) /* no starred zero found */
						{
							/* move to step 4 */
							step4(assignment, distMatrix, starMatrix, newStarMatrix, primeMatrix, coveredColumns, coveredRows, nOfRows, nOfColumns, minDim, row, col);
							return;
						}
						else
						{
							coveredRows[row]        = true;
							coveredColumns[starCol] = false;
							zerosFound              = true;
							break;
						}
					}
	}
	
	/* move to step 5 */
	step5(assignment, distMatrix, starMatrix, newStarMatrix, primeMatrix, coveredColumns, coveredRows, nOfRows, nOfColumns, minDim);
}

/********************************************************/
void step4(double *assignment, double *distMatrix, bool *starMatrix, bool *newStarMatrix, bool *primeMatrix, bool *coveredColumns, bool *coveredRows, int nOfRows, int nOfColumns, int minDim, int row, int col)
{	
	int n, starRow, starCol, primeRow, primeCol;
	int nOfElements = nOfRows*nOfColumns;
	
	/* generate temporary copy of starMatrix */
	for(n=0; n<nOfElements; n++)
		newStarMatrix[n] = starMatrix[n];
	
	/* star current zero */
	newStarMatrix[row + nOfRows*col] = true;

	/* find starred zero in current column */
	starCol = col;
	for(starRow=0; starRow<nOfRows; starRow++)
		if(starMatrix[starRow + nOfRows*starCol])
			break;

	while(starRow<nOfRows)
	{
		/* unstar the starred zero */
		newStarMatrix[starRow + nOfRows*starCol] = false;
	
		/* find primed zero in current row */
		primeRow = starRow;
		for(primeCol=0; primeCol<nOfColumns; primeCol++)
			if(primeMatrix[primeRow + nOfRows*primeCol])
				break;
								
		/* star the primed zero */
		newStarMatrix[primeRow + nOfRows*primeCol] = true;
	
		/* find starred zero in current column */
		starCol = primeCol;
		for(starRow=0; starRow<nOfRows; starRow++)
			if(starMatrix[starRow + nOfRows*starCol])
				break;
	}	

	/* use temporary copy as new starMatrix */
	/* delete all primes, uncover all rows */
	for(n=0; n<nOfElements; n++)
	{
		primeMatrix[n] = false;
		starMatrix[n]  = newStarMatrix[n];
	}
	for(n=0; n<nOfRows; n++)
		coveredRows[n] = false;
	
	/* move to step 2a */
	step2a(assignment, distMatrix, starMatrix, newStarMatrix, primeMatrix, coveredColumns, coveredRows, nOfRows, nOfColumns, minDim);
}

/********************************************************/
void step5(double *assignment, double *distMatrix, bool *starMatrix, bool *newStarMatrix, bool *primeMatrix, bool *coveredColumns, bool *coveredRows, int nOfRows, int nOfColumns, int minDim)
{
	double h, value;
	int row, col;
	
	/* find smallest uncovered element h */
	h = mxGetInf();	
	for(row=0; row<nOfRows; row++)
		if(!coveredRows[row])
			for(col=0; col<nOfColumns; col++)
				if(!coveredColumns[col])
				{
					value = distMatrix[row + nOfRows*col];
					if(value < h)
						h = value;
				}
	
	/* add h to each covered row */
	for(row=0; row<nOfRows; row++)
		if(coveredRows[row])
			for(col=0; col<nOfColumns; col++)
				distMatrix[row + nOfRows*col] += h;
	
	/* subtract h from each uncovered column */
	for(col=0; col<nOfColumns; col++)
		if(!coveredColumns[col])
			for(row=0; row<nOfRows; row++)
				distMatrix[row + nOfRows*col] -= h;
	
	/* move to step 3 */
	step3(assignment, distMatrix, starMatrix, newStarMatrix, primeMatrix, coveredColumns, coveredRows, nOfRows, nOfColumns, minDim);
}


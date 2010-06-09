
void add(double *ancMatrixUpdated,double *ancMatrix,int nr,int source, int sink)
{
	int j,p;
/* Add source => sink */
    ancMatrixUpdated[source + nr*sink] = 1;
    
    /* Add source => children(sink) */
    for(j = 0; j < nr; j++)
    {
        if (ancMatrix[sink + j*nr] == 1)
            ancMatrixUpdated[source + j*nr] = 1;
    }
    
    /* Update parents of source */
    for(p = 0; p < nr; p++)
    {
        if (ancMatrix[p + source*nr] == 1)
        {
            /* Add parent(source) => sink */
            ancMatrixUpdated[p + sink*nr] = 1;
            
            /* Add parent(source) => children(sink) */
            for(j = 0; j < nr; j++)
            {
                if (ancMatrix[sink + j*nr] == 1)
                    ancMatrixUpdated[p + j*nr] = 1;
            }
        }
    }
}

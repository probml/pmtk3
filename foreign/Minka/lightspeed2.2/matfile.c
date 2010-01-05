/* matfile utility program     
 * Allows you to read and write MAT files from the command line.
 * Useful for manipulating large data structures via a combination of
 * unix and matlab commands.
 * Run without arguments for a description of usage.
 * The file test_matfile.mat is provided for you to play with.
 *
 * Thomas P Minka 3/25/99
 * 1/29/00 added sparse matrices 
 */

#include <stdio.h>
#include <ctype.h>  /* for isspace() */
#include "mat.h"

#define Allocate(n,t) (t*)malloc((n)*sizeof(t))
#define Reallocate(p, n, t) ((p)=(t*)realloc((p),(n)*sizeof(t)))

void directory(MATFile *pmat)
{
  int i;
#if 0
  int ndir;
  char **dir;
  dir = matGetDir(pmat, &ndir);
  if (dir == NULL) {
    fprintf(stderr, "Error reading directory\n");
    exit(1);
  }
  for (i=0; i < ndir; i++) {
    printf("%s\n",dir[i]);
  }
#else
  const char *name;
  printf("Name\t\t  Size  \t     Bytes\tClass\n\n");
  for (i=0;;i++) {
    mxArray *pa = matGetNextVariableInfo(pmat, &name);
    int ndims;
    const int *dims;
    int size;
    if(pa == NULL) {
      break;
    }
    printf("%-10s  ", name);
    ndims = mxGetNumberOfDimensions(pa);
    dims = mxGetDimensions(pa);
    for(i=0;i<ndims;i++) {
      if(i == 0) printf("%10d", dims[i]);
      else printf("x%d", dims[i]);
    }
    if(mxIsSparse(pa)) {
      size = mxGetNzmax(pa)*(mxGetElementSize(pa) + sizeof(int));
      size += (mxGetN(pa)+1)*sizeof(int);
    } 
    else {
      size = mxGetNumberOfElements(pa)*mxGetElementSize(pa);
    }
    printf("\t%10d", size);
    printf("\t%s", mxGetClassName(pa));
    if(mxIsFromGlobalWS(pa)) printf(" (global)");
    printf("\n");
  }  
#endif
}

void extract(MATFile *pmat, char *var)
{
  mxArray *pa = matGetArray(pmat, var);
  int ndims;
  if(pa == NULL) {
    fprintf(stderr, "There is no variable named %s\n", var);
    exit(1);
  }
  ndims = mxGetNumberOfDimensions(pa);
  if(ndims > 2) {
    fprintf(stderr, "Cannot handle more than two dimensions.  Sorry.\n");
    exit(1);
  }
  if(mxIsSparse(pa)) {
    fprintf(stderr, "Cannot extract sparse matrices.  Sorry.\n");
    exit(1);
  }
  if(mxIsComplex(pa)) {
    fprintf(stderr, "Cannot extract complex matrices.  Sorry.\n");
    exit(1);
  }
  if(mxIsDouble(pa)) {
    int i, j;
    const int *dims = mxGetDimensions(pa);
    for(i=0;i<dims[0];i++) {
      double *p = mxGetPr(pa) + i;
      for(j=0;j<dims[1];j++) {
	printf("%g ", *p);
	p += dims[0];
      }
      printf("\n");
    }
  }
  else {
    fprintf(stderr, "Can only handle double-precision variables.  Sorry.\n");
    exit(1);
  }
  mxFree(pa);
}

/****************************************************************************/

typedef struct DoubleArray {
  double *d;
  int len, bufsize;
} DoubleArray;

DoubleArray *DoubleArray_Create(void) 
{
  DoubleArray *a = Allocate(1, struct DoubleArray);
  a->bufsize = 32;
  a->len = 0;
  a->d = Allocate(a->bufsize, double);
  return a;
}

void DoubleArray_Free(DoubleArray *a)
{
  free(a->d);
  free(a);
}

void DoubleArray_Set(DoubleArray *a, int index, double value)
{
  if(index >= a->bufsize) {
    do {
      a->bufsize *= 2;
    } while(index >= a->bufsize);
    Reallocate(a->d, a->bufsize, double);
  }
  if(index >= a->len) a->len = index+1;
  a->d[index] = value;
}

/****************************************************************************/

typedef struct IntArray {
  int *d;
  int len, bufsize;
} IntArray;

IntArray *IntArray_Create(void) 
{
  IntArray *a = Allocate(1, struct IntArray);
  a->bufsize = 32;
  a->len = 0;
  a->d = Allocate(a->bufsize, int);
  return a;
}

void IntArray_Free(IntArray *a)
{
  free(a->d);
  free(a);
}

void IntArray_Set(IntArray *a, int index, int value)
{
  if(index >= a->bufsize) {
    do {
      a->bufsize *= 2;
    } while(index >= a->bufsize);
    Reallocate(a->d, a->bufsize, int);
  }
  if(index >= a->len) a->len = index+1;
  a->d[index] = value;
}

/****************************************************************************/

typedef void ScanFunc(int r, int c, double d, void *info);

void scan(int *rows_return, int *cols_return, ScanFunc *f, void *info)
{
  int rows, cols, i;
  double d;
  FILE *fp = stdin;

  /* Use the first line to determine the number of columns */
  for(i=0;;) {
    int c = getc(fp);
    if(c == '\n') break;
    if(isspace(c)) continue;
    ungetc(c, fp);
    if(fscanf(fp, "%lg", &d) < 1) {
      fprintf(stderr, "scan failed: expected a real number\n");
      goto error;
    }
    f(0, i, d, info);
    i++;
  }
  cols = i;
  
  /* Read the rest of the lines */
  for(rows=1;;rows++) {
    int j;
    for(j = 0; j < cols; j++) {
      if(fscanf(fp, "%lg", &d) < 1) {
	if(!feof(fp)) {
	  fprintf(stderr, "scan failed: expected a real number\n");
	  goto error;
	}
	else if(j > 0) {
	  fprintf(stderr, "scan failed: unexpected end of file\n");
	  goto error;
	}
	break;
      }
      f(rows, j, d, info);
    }
    if(feof(fp)) break;
  }
  *rows_return = rows;
  *cols_return = cols;
error:
  return;
}

void transpose(double *dest, double *src, int rows, int cols)
{
  double *dest_save = dest;
  int i,j;
  for(i=0;i<rows;i++) {
    dest = dest_save + i;
    for(j=0;j<cols;j++) {
      *dest = *src++;
      dest += rows;
    }
  }
}

struct FullInfo {
  DoubleArray *a;
  int index;
};

void ScanFull(int r, int c, double d, struct FullInfo *info)
{
  DoubleArray_Set(info->a, info->index++, d);
}

struct SparseInfo {
  DoubleArray *data;
  IntArray *ir, *jc;
  int next_row;
  int index;
};

void ScanSparse(int r, int c, double d, struct SparseInfo *info)
{
  if(d == 0) return;
  DoubleArray_Set(info->data, info->index, d);
  IntArray_Set(info->ir, info->index, c);
  /* start of new row? */
  if(r >= info->next_row) {
    /* fill in all rows up to r */
    for(; info->next_row <= r; info->next_row++) {
      IntArray_Set(info->jc, info->next_row, info->index);
    }
  }
  info->index++;
}

void update(MATFile *pmat, char *var, int global, int sparse)
{
  int rows, cols, status;
  mxArray *pa;
  if(sparse) {
    int nzmax;
    struct SparseInfo *info = Allocate(1, struct SparseInfo);
    info->index = 0;
    info->next_row = 0;
    info->data = DoubleArray_Create();
    info->ir = IntArray_Create();
    info->jc = IntArray_Create();

    scan(&rows, &cols, (ScanFunc*)ScanSparse, info);
    /* fill out jc */
    for(; info->next_row <= rows; info->next_row++) {
      IntArray_Set(info->jc, info->next_row, info->index);
    }
    /* note rows and cols are swapped */
    nzmax = info->index;
    if(rows > nzmax) nzmax = rows;
    pa = mxCreateSparse(cols, rows, nzmax, mxREAL);
    memcpy(mxGetPr(pa), info->data->d, info->index*sizeof(double));
    memcpy(mxGetIr(pa), info->ir->d, info->index*sizeof(int));
    memcpy(mxGetJc(pa), info->jc->d, (rows+1)*sizeof(int));

    DoubleArray_Free(info->data);
    IntArray_Free(info->ir);
    IntArray_Free(info->jc);
    free(info);
  }
  else {
    struct FullInfo *info = Allocate(1, struct FullInfo);
    info->a = DoubleArray_Create();
    info->index = 0;
    scan(&rows, &cols, (ScanFunc*)ScanFull, info);
    pa = mxCreateDoubleMatrix(rows, cols, mxREAL);
    transpose(mxGetPr(pa), info->a->d, rows, cols);
    DoubleArray_Free(info->a);
    free(info);
  }
  mxSetName(pa, var);
  if(global) status = matPutArrayAsGlobal(pmat, pa);
  else status = matPutArray(pmat, pa);
  if(status) {
    fprintf(stderr, "matPutArray failed\n");
    exit(1);
  }
}

void delete(MATFile *pmat, char *var)
{
  if(matDeleteArray(pmat, var)) {
    fprintf(stderr, "matDeleteArray failed\n");
    exit(1);
  }
}

void printUsage(void)
{
  fprintf(stderr, "matfile utility program by Thomas P Minka\n");
  fprintf(stderr, "\nusage: matfile cmd file [var]\n\n");
  fprintf(stderr, "cmd is one of\n");
  fprintf(stderr, "\tt\tList the contents of file\n");
  fprintf(stderr, "\tx\tExtract var and print on stdout\n");
  fprintf(stderr, "\tu\tUpdate var from stdin\n");
  fprintf(stderr, "\tug\tSame as u but make var global\n");
  fprintf(stderr, "\tus\tSame as u but make var sparse (result will be transposed)\n");
  fprintf(stderr, "\td\tDelete var\n");
  exit(1);
}

int main(int argc, char *argv[])
{
  MATFile *pmat;
  char *cmd, *file;

  if(argc < 3) {
    printUsage();
  }
  cmd = argv[1];
  file = argv[2];

  if((cmd[0] == 'u') || (cmd[0] == 'd')) {
    pmat = matOpen(file, "u");
    if((pmat == NULL) && (cmd[0] == 'u')) {
      pmat = matOpen(file, "w");
    }
  }
  else {
    pmat = matOpen(file, "r");
  }
  if(pmat == NULL) {
    fprintf(stderr, "Cannot open file %s: ", file);
    perror("");
    exit(1);
  }

  switch(cmd[0]) {
  case 't':
    if(argc != 3) printUsage();
    directory(pmat);
    break;
  case 'x':
    if(argc != 4) printUsage();
    extract(pmat, argv[3]);
    break;
  case 'u':
    if(argc != 4) printUsage();
    update(pmat, argv[3], cmd[1] == 'g', cmd[1] == 's');
    break;
  case 'd':
    if(argc != 4) printUsage();
    delete(pmat, argv[3]);
    break;
  default:
    fprintf(stderr, "Unknown command `%s'\n", cmd);
  }

  matClose(pmat);
  exit(0);
}

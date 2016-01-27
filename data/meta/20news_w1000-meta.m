% PMTKdescription Top 1000 words from  the 20newsgroups data
% PMTKsource http://people.csail.mit.edu/jrennie/20Newsgroups/
% PMTKtypeX Sparse count data
% PMTKtypeY discrete (20)
% PMTKncases 11256
% PMTKndims 1000
% PMTKcreated Ben Marlin

num_class: 20
          vocab: {1x1000 cell}
         trainW: [11256x1000 double]
         trainC: [11256x20 double]
          testW: [7489x1000 double]
          testC: [7489x20 double]
    class_names: {20x1 cell}

Ben Marlin wrote:

"I got the raw data from Jason Rennie's website. The vocabulary list
included all unique tokens in the original posts. I removed a standard
list of stop words, ran a stemmer on the vocabulary list, grouped
words with the same stem into word groups, and selected word groups to
keep using mutual information and frequency thresholding. Basically, I
kept the top 1000 word groups by mutual information that were above
the 25th percentile in frequency. Using the top 1000 words resulted in
29 empty documents, which I dropped. There are about 11K training
documents left, but the training document-word matrix is 97% sparse
(ie: most counts are 0). The columns of the data matrix are sorted by
MI from highest to lowest so, if you want 100 word groups with the
highest MI, you can just use use the first 100 columns."


function text = stream2text(stream)
  % converts an array of integers representing letters and spaces, to a
  % charachter array
  table = ['a':'z' ' '];
  text = table(stream);
  
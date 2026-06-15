# 1111111111111111111111111111111111111111111111111111111111111111

clear all

binarystring = "1100110001001100000001000101101010010010001100101010001001100010";

c = 0;

fprintf(stderr, '  {\n');
fprintf(stderr, '    "name" : "egg",\n');
fprintf(stderr, '    "representation" : {\n');
fprintf(stderr, '      "matrix" :  [\n');

for i = binarystring
  c++;
  fprintf(stderr, strcat('         ["q', int2str(c), '", "*", "l", "q', int2str(c), '"],\n'));
  fprintf(stderr, strcat('         ["q', int2str(c), '", "0", "l", "q', int2str(c + 1), '"],\n'));
  if i == '1'
    fprintf(stderr, strcat('         ["q', int2str(c), '", "1", "l", "q', int2str(c + 1), '"],\n'));
  else
    fprintf(stderr, strcat('         ["q', int2str(c), '", "1", "0", "q', int2str(c), '"],\n'));
  end
end 

c++;
fprintf(stderr, strcat('         ["q', int2str(c), '", "*", "h", "q', int2str(c), '"],\n'));
fprintf(stderr, strcat('         ["q', int2str(c), '", "0", "h", "q', int2str(c + 1), '"],\n'));
fprintf(stderr, strcat('         ["q', int2str(c), '", "1", "h", "q', int2str(c + 1), '"]]\n'));

fprintf(stderr, '    }\n');
fprintf(stderr, '  }\n');

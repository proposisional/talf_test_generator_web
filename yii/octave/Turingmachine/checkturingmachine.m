function passtest = checkturingmachine
% checkturingmachine
%
% ===============================================================
%
%   fjv, 20/12/2021   GNU GPL v3.0
% ===============================================================


  passtest = true;
  for inputvaluedecimal = 0:100;
    inputvaluebinary = dec2bin(inputvaluedecimal);
    result = turingmachine("successor_binary", sprintf("*%s*", inputvaluebinary), "none");
    outputvaluebinary  = result{1}.content(2:end-1);
    outputvaluedecimal = bin2dec(outputvaluebinary);
    if outputvaluedecimal != inputvaluedecimal + 1
      passtest = false;
      fprintf(stderr, "f(%d) = %d\n", inputvaluedecimal, outputvaluedecimal );
      fprintf(stderr, "f(%s) = %s\n", inputvaluebinary,  outputvaluebinary);
      break
    end
  end

end

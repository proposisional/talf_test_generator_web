function [set] = createRandomSet(option)

    sigmaLetters = ['a', 'b', 'c', 'd', 'e'];
    sigmaNumbers = ['1', '2', '3', '4', '5'];

    if option == 1
        sigma = sigmaNumbers;
    elseif option == 2
        sigma = [sigmaLetters sigmaNumbers];
    else
        sigma = sigmaLetters;
    end

    n = randi([0, length(sigma)]);
    set = sigma(randperm(length(sigma), n));
    set = sort(set);
end

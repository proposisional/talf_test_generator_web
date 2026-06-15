function cadena = produce(G, numcadenas, maxderivacion, outputformat, semilla)
% string = produce(G, numcadenas, maxderivacion, outputformat, semilla)
%
% Produce una cadena de L(G) tras una derivacion de longitud
% no superior a maxderivacion. Si no se ha alcanzado una cadena, devuelve
% la forma sentencial tras maxderivacion pasos. Si no se asigna valor a maxderivacion,
% entonces se impone un limite de 1000 para evitar bucles infinitos.
% La semilla se utiliza para la generación de números aleatorios,
% si se usa sin límite para la longitud de la derivación, maxderivacion será NaN.
%
% outputformat : "text" (default) / "string" / "stringLaTeX" / "none" 
%
% Ejemplos:
%
% produce('impar', 1, 3);
% (
%   {A, B},
%   {@},
%   {
%     A → @
%     A → @B
%     B → @A
%   },
%   A
% )
%
% 
% A => @B => @@A => @@@B
%
% 
% produce('par', 1, NaN, 3);
% (
%   {A, B},
%   {@},
%   {
%     A → @B
%     B → @A
%     B → @
%   },
%   A
% )
% 
% 
% A => @B => @@A => @@@B => @@@@%
%
% 
% ===============================================================
%
%   fjv, 01/10/2023   generar varias cadenas
%   fjv, 22/09/2023   semilla para generación de aleatorios
%   fjv, 10/10/2013   leer gramatica si la entrada es un nombre de fichero
%   fjv, 27/10/2004   GNU GPL v3.0
%
% ===============================================================

## limite en el numero de pasos de produccion para evitar bucle infinito
maxpasos = 1000;

addpath('../util/');

## leer gramatica si es el nombre
if ischar(G)
  G = loadrepresentation('grammars', G);
end

if !exist('numcadenas','var') || isnan(numcadenas)
  numcadenas = 1;
end

if !exist('maxderivacion','var') || isnan(maxderivacion)
  maxderivacion = maxpasos;
end

## semilla
if !exist('semilla','var')
  semilla = rand(1, numcadenas);
elseif numel(semilla) != numcadenas
  error('number of strings and seeds not congruent...')
end

## salida en pantalla
if !exist('outputformat', 'var')
  outputformat = 'text';
end

if !strcmp(outputformat, 'none')
  prettyprintgrammar(G, outputformat);
end

## numero de reglas
numreglas = size(G.P, 2);


for derivacion = 1 : numel(semilla)

  rand('seed', semilla(derivacion));

  fprintf(' \n')

  ## comenzar a derivar por el axioma
  formasentencial = G.S;								

  fprintf('\n%s', formasentencial);

  longitudderivacion = 0;
  while longitudderivacion < maxderivacion
    ## la forma sentencial no contiene simbolos no terminales
    escadena = strcmp(formasentencial, strtok(formasentencial, [G.N{:}]));
    ## decidir si producir o continuar la derivacion
    if escadena && ceil(2 * rand - 1) == 1
      cadena = formasentencial;
      break;
    end
      
    ## seleccion de las reglas en orden aleatorio
    randomrules = randperm(numreglas);
    for rule = randomrules
%      rule
      produccion = producir1paso(formasentencial, G.P{rule});
      ## comprueba variacion en la forma sentencial
      hayproduccion = ~strcmp(produccion, formasentencial);
      ## la regla produjo en un paso
      if hayproduccion
        formasentencial = produccion;
        fprintf(' => %s', formasentencial);
        break;
      end
    end
      
    longitudderivacion = longitudderivacion + 1;
  end

  fprintf('\n');
end


function cadena = producir1paso(cadena, rule)
% cadena = producir1paso(cadena, regla)
%
% Produce en un paso una cadena por aplicacion de la regla.
%
% Ejemplo:
%       cadena = producir1paso('123123123', {'123', '456'})
%
% puede producir directamente '456123123', '123456123' o '123123456'.

## conversion del antecedente de la regla en cadena
antecedente = rule{1};
if strcmp(antecedente, 'ε')
  antecedente = '';
end
## conversion del consecuente de la regla en cadena
consecuente = rule{2};
if strcmp(consecuente, 'ε')
  consecuente = '';
end

## comparar solo si el antecedente es mayor que la forma cadena
if length(cadena) < length(antecedente)
  pos = [];
else
  ## encuentra el antecedente en la cadena
  pos = strfind(cadena, antecedente);
end

## si el antecedente es subcadena de la cadena
if ~isempty(pos)
  ## selecciona una posicion donde realizar la produccion
  i = pos(ceil(length(pos) * rand));

  ## prefijo anterior a la subcadena a sustituir
  if i > 1
    prefijo = cadena(1 : i - 1);
  else
    prefijo = '';
  end

  if i < length(cadena)
    sufijo = cadena(i + length(char(rule{1})) : length(cadena));
    ## sufijo posterior a la subcadena a sustituir
  else
    sufijo = '';
  end
  ## concatenacion de las tres subcadenas
  cadena = strcat(prefijo, consecuente, sufijo);
end

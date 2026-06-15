function drawtree(string)

  ## width of lines
  linewidth = 0.5;

  ## rotation angle in degrees
  ## '+' = rotate anticlockwise;
  ## '-' = rotate clockwise.
  angle = -30;

  ## length of each segment
  length_G = 1;
  length_F = 2;

  ## initial line coordinates and angle (0 = upwards)
  x = 0;
  y = 0;
  a = 0;
  ## convert degrees to radians
  angle = angle / 180 * pi;

  ## level of stacking for bracketed expressions
  stackindex = 0;

  ## bounding box limits initialization
  minx = maxx = miny = maxy = 0;

  ## canvas
  clf;
  grid off;
  axis off;

  stack = [];
  for idsymbol = 1:numel(string)

    switch string(idsymbol)

      ## case of a branch
      case 'G'
        ## branch tip
        newx = x + length_G * sin(a);
        newy = y + length_G * cos(a);

        ## plot segment
        line([x newx], [y newy], 'color', 'k', 'linewidth', linewidth);

        ## branch tip is the new starting point
        x = newx;
        y = newy;

        ## update bounding box
        if (x < minx) minx = x; end
        if (x > maxx) maxx = x; end
        if (y < miny) miny = y; end
        if (y > maxy) maxy = y; end

      case 'F'
        ## branch tip
        newx = x + length_F * sin(a);
        newy = y + length_F * cos(a);

        ## plot segment
        line([x newx], [y newy], 'color', 'k', 'linewidth', linewidth);

        ## branch tip is the new starting point
        x = newx;
        y = newy;

        ## update bounding box
        if (x < minx) minx = x; end
        if (x > maxx) maxx = x; end
        if (y < miny) miny = y; end
        if (y > maxy) maxy = y; end

      ## rotate anticlockwise
      case '+'
        a = a + angle;

      ## rotate clockwise
      case '-'
        a = a - angle;
        
      ## stack current position
      case '['
        stackindex = stackindex + 1 ;
        stack(stackindex).x = x ;
        stack(stackindex).y = y ;
        stack(stackindex).a = a ;

      ## restore stacked position
      case ']'
        x = stack(stackindex).x ;
        y = stack(stackindex).y ;
        a = stack(stackindex).a ;
        stackindex = stackindex - 1 ;

      otherwise
        error("Symbol %s unknown while drawing the tree...", string(idsymbol));
    end
    
  end

  ## sets data aspect ratio
  daspect([1,1,1])

  ## show bounding box only
  axis([minx maxx miny maxy]);
  
end

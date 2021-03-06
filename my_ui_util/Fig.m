classdef Fig < handle
    %%
    %
    %%
    % FEATURE
    %
    % * subplot automatic layout
    % * title featured variable name
    %
    %%
    % TODO
    %
    % * title class type
    % * title image size
    %
    %%
    % WONT DO
    %
    % * do mat2gray for matrix
    % * show hist, bar...
    %
    %%
    % Example
    %
    %   Football = imread('football.jpg');
    %   Cameraman = imread('cameraman.tif');
    %   Ui.subimshow(Football, Cameraman);
    %   Ui.subimshow('kids.tif',rgb2gray(Football), im2bw(Cameraman));
    %
    %  Project website: https://github.com/baidut/openvehiclevision
    %  Copyright 2016 Zhenqiang Ying [yingzhenqiang-at-gmail.com].
    %
    %%
    % See also
    %
    % Ui.subimshow, Ui.subimshow, Ui.subplot.
    
    %% Properties
    properties (GetAccess = public, SetAccess = private)
        h;
    end
    
    %% Figure
    %   F = Fig;
    %   figure(F); % set F current figure.
    %   imshow('peppers.png');
    %   F.maximize();
    methods (Access = public)
        function F = Fig(titlestr, varargin)
            F.h = figure(varargin{:});
            if nargin > 1
                F.title(titlestr);
            end
        end
        function h = figure(F)
            figure(F.h);
            h = F.h;
        end
        function title(F, string)
            if nargin == 0
                string = inputname(1);
            end
            F.h.NumberTitle = 'off';
            F.h.Name = string;
        end
        function h = maximize(F)
            F.h.Position = get(0,'ScreenSize');
            h = F.h;
        end
    end
    
    %% eachsubplot, subimshow, subplot,
    methods (Static)
        % subimshow
        function h = subimshow(varargin)
            %UI.SUBIMSHOW(I,J,K,L...)
            % USAGE:
            % 	RawImage = imread('peppers.png');
            % 	GrayImage = rgb2gray(RawImage);
            % 	BinaryImage = im2bw(RawImage);
            % 	BinaryImage_otsu = im2bw(GrayImage, graythresh(GrayImage));
            %   Ui.subimshow(RawImage,GrayImage,BinaryImage,BinaryImage_otsu)
            
            titles = cell(1,numel(varargin));
            
            for n = 1:numel(varargin)
                arg = varargin{n};
                name = inputname(n);
                
                if isempty(name)
                    titles{n} = class(arg);
                else
                    titles{n} = sprintf('(%s) \\color{blue}%s',...
                        class(arg), Fig.name2str(name));
                end
            end
            h = Fig.eachsubplot(@imshow, varargin, titles);
            %, variable name of
            % I,J,K,... will be titled.
            % default title
        end
        
        function h = subplot(varargin)
            %UI.SUBPLOT(I,J,K) is same as
            % subplot(221); plot(I);
            % subplot(222); plot(J);
            % subplot(223); plot(K);
            %
            % USAGE
            %  x = 1:50;
            %  Ui.subplot(sin(x),cos(x),sin(2*x),cos(2*x));
            
            h = Fig.eachsubplot(@plot, varargin);
        end
        
        function h = eachsubplot(func, args, names)
            %  EACHSUBPLOT(f,{I,J,K},{'1','2','3'}) is same as
            %  subplot(221); title('1'); f(I);
            %  subplot(222); title('2'); f(J);
            %  subplot(223); title('3'); f(K);
            %
            %  h = eachsubplot(func,args,names)
            %
            % INPUTS
            %
            % * func - handle of function which takes one input
            % * args - cell array of variables
            % * names - cell array of variable names
            %
            % OUTPUTS
            %
            % * h - handle of the figure
            %
            % NOTE
            %
            % 	this function will new a figure if current figure is not
            % empty and hold is off.
            %
            % USAGE
            %
            %   Ui.eachsubplot(@imshow, {'kids.tif','cameraman.tif'});
            %
            % SEE ALSO Ui.name2str, Ui.subimshow, Ui.subplot.
            
            narg = numel(args);
            titles = cell(1,narg);
            
            if nargin>2
                assert(narg == numel(names));
                titles = names;
            end
            
            h = gcf;
            if ~isempty(h.Children) && ~ishold
                h = figure;
            end
            
            r = floor(sqrt(narg));
            c = ceil(narg/r);
            
            holdstat = ishold;% if hold is on, and 0 if it is off.
            
            for n = 1:narg
                arg = args{n};
                if ~isempty(arg)
                    subplot(r, c, n);
                    if ~isempty(titles{n})
                        title(titles{n});
                        hold on;
                    end
                    % call function
                    func(arg); % default title can be rewritten
                end
            end
            
            if ~holdstat, hold off; end
        end
        
        function subimwrite() % format_string %t for title
            h = gcf;
            h.Children
            for a = h.Children' % 1*n
                whos a
                if isa(a,'matlab.graphics.axis.Axes') % Axes UIControl
                    % "(ImCtrl) \color{blue}Ours" -> "Ours"
                    name = regexprep(a.Title.String,'\(\w*\)\s\\\w*{\w*}','');
                    imwrite( getimage(a), [name '.jpg']); % eps
                end
            end
        end
        
        %% TODO: recovery name
        function str = name2str(name)
            %NAME2STR convert an identifier to a string
            % name      -->      	string
            % 'RawImg'           	'Raw Img'
            % 'RGB_R'   			'RGB_R'
            % 'FilteredImg_roi'   	'FilteredImg_r_o_i'
            %
            % USAGE:
            %   Ui.name2str('FilteredImg_RectRoi')
            %
            % SEE ALSO title.
            
            % 'RawImg' -> 'Raw Img'
            str = [name(1) regexprep(name(2:end),'([A-Z])[a-z]',' $&')];
            
            % or 'rawImage' -> 'Raw image'
            %
            % name = regexprep(name,'[A-Z]',' $&'); % 'rawImage' -> 'raw Image'
            % name = lower(name);					% -> 'raw image'
            % name(1) = name(1) + 'A' - 'a';		% -> 'Raw image'
            
            % subscript: IMAGE_GRAY - title('IMAGE_G_R_A_Y')
            
            S = regexp(str, '_', 'split');
            if length(S) == 2
                s1 = S{1}; % Filtered
                s2 = S{2}; % Mean
                s_ = repmat('_',1,length(s2));
                t = [s_; s2];
                s2 = t(:)' ; %_M_e_a_n
                str = [s1, s2];
            end
        end
        
        function subplotxy(x,y)
            % rearrange the subplot #rows and #cols
        end
        
        function image = montage()
            % subplot images to one montage image
        end
    end
    
end% classdef
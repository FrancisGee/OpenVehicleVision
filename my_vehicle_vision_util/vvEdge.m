classdef vvEdge
    %VVEDGE do edge extraction
    %
    %   Example
    %   -------
    %
    %   Project website: https://github.com/baidut/openvehiclevision
    %   Copyright 2016 Zhenqiang Ying.
    
    %% Public properties
    % properties (GetAccess = public, SetAccess = private)
    % end
    
    %% Static methods
    methods (Static)
        function test(I)
            if nargin == 0, I = imread('circuit.tif');
            end
            
            thresh = Slider([0 0.2]);
            direction = Popupmenu({'both','horizontal','vertical'});
            %sigma = Slider([0 0.2]);
            thinning = Popupmenu({'thinning','nothinning'});
            
            Sobel = ImCtrl(@edge, I, 'sobel', thresh, direction, thinning);
            Prewitt = ImCtrl(@edge, I, 'prewitt', thresh, direction, thinning);
            Roberts = ImCtrl(@edge, I, 'roberts', thresh, thinning);
            
            F = Fig;
            F.maximize();
            F.subimshow(I, Sobel, Prewitt, Roberts);
            % Ui.subplot(I, roberts); % ,sobel, prewitt
            % Ui.subplot(roberts, I);
        end
        
        function testCanny(I)
            if nargin == 0, I = imread('circuit.tif');
            end
            
            % if THRESH is empty ([]), edge chooses low and high values automatically.
            range = RangeSlider([0 1]);
            sigma = Slider([0 10]);
            
            sobel = ImCtrl(@edge, I, 'canny', range, sigma);
            Fig.subimshow(I, sobel);
        end
        
        function E=pdollar(I)
            % Demo for Structured Edge Detector (please see readme.txt first).
            
            %% set opts for training (see edgesTrain.m)
            opts=edgesTrain();                % default options (good settings)
            opts.modelDir='models/';          % model will be in models/forest
            opts.modelFnm='modelBsds';        % model name
            opts.nPos=5e5; opts.nNeg=5e5;     % decrease to speedup training
            opts.useParfor=0;                 % parallelize if sufficient memory
            
            %% train edge detector (~20m/8Gb per tree, proportional to nPos/nNeg)
            tic, model=edgesTrain(opts); toc; % will load model if already trained
            
            %% set detection parameters (can set after training)
            model.opts.multiscale=0;          % for top accuracy set multiscale=1
            model.opts.sharpen=2;             % for top speed set sharpen=0
            model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
            model.opts.nThreads=4;            % max number threads for evaluation
            model.opts.nms=0;                 % set to true to enable nms
            
            %% evaluate edge detector on BSDS500 (see edgesEval.m)
            if(0), edgesEval( model, 'show',1, 'name','' ); end
            
            %% detect edge and visualize results
            %I = imread('peppers.png');
            tic, E=edgesDetect(I,model); toc
%             figure(1); im(I); figure(2); im(1-E);
            
        end
        
    end% methods
end% classdef


% function imshowedge(Raw, method)
% %IMSHOWEDGE extract the edge feature of a image.
% % USAGE:
% %  normal case
% % 	IMSHOWEDGE('pictures/lanemarking/light_sbs_vertical_www.jpg');
% % 	foreach_file_do('pictures/lanemarking/*light*.picture', @IMSHOWEDGE, 'canny');
% %  effect of shadow
% % 	IMSHOWEDGE('pictures/lanemarking/shadow/IMG00576.jpg', 'canny');
% % 	IMSHOWEDGE('pictures/lanemarking/shadow/IMG00576.jpg');

% Raw = im2gray(Raw);

% if nargin < 2 % no specifies the method
% Sobel = edge(Raw, 'sobel', 0.05);
% Roberts = edge(Raw, 'roberts', 0.05);
% Prewitt = edge(Raw, 'prewitt', 0.05);
% LoG = edge(Raw, 'log', 0.003, 2.25);
% Canny = edge(Raw, 'canny', [0.04 0.10], 1.5);
% h = fspecial('gaussian',5); %��˹�˲�
% Zerocross = edge(Raw,'zerocross',[ ],h); %zerocrossͼ���Ե��ȡ

% figure;
% implot(Raw, Sobel, Roberts, Prewitt, LoG, Canny, Zerocross);
% else
% Edge = edge(Raw, lower(method));
% figure;
% implot(Raw, Edge);
% end

% % % Ĭ�ϲ����£�SobelЧ�����
% % % �����Է�����ֵT
% % T = [];
% % dir = 'both';
% % Sobel = edge(Raw, 'sobel', T, dir);
% % Roberts = edge(Raw, 'roberts', T, dir);
% % Prewitt = edge(Raw, 'prewitt');
% % % default T and sigma
% % LoG = edge(Raw, 'log');
% % Canny = edge(Raw, 'canny');
% % TODO:
% % 45���Ե��Sobel
% % zerocross
% % ���Ʋ��������Ч��ͼ ����������
% % ����ĳ������

% % �ο� ����ͼ�����Matlabʵ��

% % % matlab ��Ե��ȡ
% % close all
% % clear all
% % Raw=imread('tig.jpg'); %��ȡͼ��
% % Raw1=im2double(Raw); %����ͼ���б��˫����
% % Raw2=rgb2gray(Raw1); %����ɫͼ��ɻ�ɫͼ
% % [thr, sorh, keepapp]=ddencmp('den','wv',Raw2);
% % Raw3=wdencmp('gbl',Raw2,'sym4',2,thr,sorh,keepapp); %С������
% % Raw4=medfilt2(Raw3,[9 9]); %��ֵ�˲�
% % Raw5=imresize(Raw4,0.2,'bicubic'); %ͼ���С
% % BW1=edge(Raw5,'sobel'); %sobelͼ���Ե��ȡ
% % BW2=edge(Raw5,'roberts'); %robertsͼ���Ե��ȡ
% % BW3=edge(Raw5,'prewitt'); %prewittͼ���Ե��ȡ
% % BW4=edge(Raw5,'log'); %logͼ���Ե��ȡ
% % BW5=edge(Raw5,'canny'); %cannyͼ���Ե��ȡ
% % h=fspecial('gaussian',5); %��˹�˲�
% % BW6=edge(Raw5,'zerocross',[ ],h); %zerocrossͼ���Ե��ȡ
% % figure;
% % subplot(1,3,1); %ͼ����Ϊһ������ͼ����һ��ͼ
% % imshow(Raw2); %��ͼ
% % figure;
% % subplot(1,3,1);
% % imshow(BW1);
% % title('Sobel����');
% % subplot(1,3,2);
% % imshow(BW2);
% % title('Roberts����');
% % subplot(1,3,3);
% % imshow(BW3);
% % title('Prewitt����');

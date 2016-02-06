function readRoad(str)
% RawVideo 1280:720 ��ȡԭʼ֡�����Ԥ����Ԥ�����640 480 ��ȡ�ķ�ʽ
% ֱ��resize �򳤿�ȱ仯

% ��תͼ 1.ֱ��תΪ���ͼ 2.��ȡROI �ٽ���ת��

% debarrel �ƺ��е���֣���Ҫ�ۺϿ���IPM
files = str2files(str);%* 0346 1201
for n = 1:numel(files)
    preprocess(files{n});
end

end

% ��ת��Ӱ��任���� ʧ�治��Ӱ�� ��ת�󣬵��ڼ���

function preprocess(file)
[~,filename,~] = fileparts(file);
% figure;maxfig;
% set(gcf,'outerposition',get(0,'screensize'));
% foreach_file_do('%datasets\pku\1\*.jpg', @(f)readRoad(imread(f)));
%
%
% if nargin < 2
% 	info = [];
% end
%RawImg = imresize(RawImg,0.5);
RawImg = imread(file);
Debarrel = vvPreproc.debarrel(RawImg, -0.2, 'bordertype', 'fit');%-0.3); %-0.32 ƫ��
%imshow(Debarrel);

Derotate = vvPreproc.derotate(Debarrel, 2.5);
% implot(RawImg, Debarrel, Derotate);
% hold on;
%imshow(Derotate(end/5:end*4/5,end/5:end*4/5,:));
%imshow(Derotate(end/5:end*4/5,:,:));

%vvIPM.proj2topview(Derotate);

%% output 640x480 IPM image
load tform.mat
nRows = 160; nCols = 214;
I = vvIPM.proj2topview(Derotate, movingPoints,[nCols nRows], ...
    'OutputView', imref2d([3*nRows, 3*nCols],[-nCols 2*nCols], [-nRows, 2*nRows]));
imwrite(I(:,2:end-1,:), ['%datasets/pku/640x480IPM/', filename, '.jpg']);

%% ROI
%Roi = Derotate(149:628,337:976,:);
%imshow(Roi);

%% Save results.
% imwrite(Derotate,sprintf('%%datasets/pku/rotate/%s.jpg',filename));% IPM
% imwrite(Roi,sprintf('%%datasets/pku/640x480/%s.jpg',filename));

end
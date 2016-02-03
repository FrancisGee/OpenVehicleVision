
function make_video(out_file,img_filter)
% make avi video 
% out_file 'output_avi_file_name'
% img_filter '*.ppm'
% clear all; close all; clc;
srcDir=uigetdir('Choose source directory.'); %���ѡ����ļ���
cd(srcDir);
allnames=struct2cell(dir(img_filter));
[k,len]=size(allnames); %����ļ��ĸ���


%aviobj = avifile(out_file,'compression','none');
v = VideoWriter(out_file);
open(v);
for i=1:len
    %���ȡ���ļ�
    name=allnames{1,i};
    rgb=imread(name); %��ȡ�ļ�
    %�ж�ͼ���Ƿ�Ϊ�Ҷ�ͼ��
	if numel(size(rgb))>2
	 %��ɫͼ��
		I=rgb;
	else
		I(:,:,1)=rgb;
		I(:,:,2)=rgb;
		I(:,:,3)=rgb;
	end
    % aviobj = addframe(aviobj,I);
	writeVideo(v,I);
end
%aviobj = close(aviobj);
close(v);
msgbox(strcat(out_file,' OK!'));

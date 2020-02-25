    close all; clear all; clc;
    load imgfildata
    % kullan�c�ya dosya se�tirme i�lemi
    [dosya,dosyaYolu] = uigetfile({'*.jpg;*.jpeg;  *.bmp; *.png; *.tif'},'Bir g�r�nt� se�in');
    dosya = [dosyaYolu,dosya];
    image = imread(dosya);
    image = imresize(image,[600 800]); 
%  figure();imshow(image);
    gri_resim = rgb2gray(image);    
    th = graythresh(gri_resim);
    BW_resim = im2bw(gri_resim,th);
%      figure();imshow(BW_resim);
    BW_resim=bwareaopen(BW_resim,200);
%       figure();imshow(BW_resim);
    %% kenar bulma
edge_resim = edge(BW_resim,'sobel');
% figure();imshow(edge_resim);
SE= strel('square',2); 
edge_resim = imdilate(edge_resim, SE);
%     figure();imshow(edge_resim);

    %% KENAR OLAN YERLER� DOLDURMA ��LEM� BU B�ZE PLAKANIN B�LGES� GOSTERM�� OLACAK 
    
fill_image = imfill(edge_resim,'holes');
%     figure();imshow(fill_image);

    % �MERODE �LE BAZI PIKSELLER� KALDIRMAK 
    erode_resim = fill_image;
  
     for x = 1:3
        erode_resim = imerode(erode_resim,SE);
          
     end
%      figure();imshow(erode_resim);
    %%  


  %B�NARY G�R�NT� �LE �IKARILMI� G�R�NT� �ARPMIMI  PLAKA KARAKTER� N� ALMAK
  %���N YAPILDI
    karakter_resim= BW_resim.*erode_resim;
     figure();imshow(karakter_resim);

   % �ABLON E�LE�T�RME ���N KARAKTERLER�N ���N�N BEYAZ OLMASI GEREKL�
  karakter_resim = ~karakter_resim;
  figure();imshow(karakter_resim);
    erode_karakter_resim = imclearborder(karakter_resim);
    
%    figure();imshow(erode_karakter_resim);
    % BAZI G�R�LT�LER KALDIRILDI  
    for x = 1:3
        erode_karakter_resim = imerode(erode_karakter_resim,SE);
    end
    
%  figure();imshow(erode_karakter_resim)

    dilate_karakter_resim = erode_karakter_resim;
  % PLAKA KARAKTERLE� DAHA �Y� G�Z�KMES� ���N GEN��LET�LD� 
    for x = 1:2
        dilate_karakter_resim = imdilate(dilate_karakter_resim,SE);
    end 
    %%   KARAKTERLER�N BEL�RLENMES� 
 figure();imshow(dilate_karakter_resim)
[etiketler ,Nesneler ]= bwlabel(dilate_karakter_resim);

   nesneOzellikler = regionprops(etiketler,'BoundingBox');
for n =1 : Nesneler
   rectangle('Position',nesneOzellikler(n).BoundingBox, 'EdgeColor','r','LineWidth',2);

end
% t�m plaka karakterlerini finalCikis de�i�keninde saklayaca��m
finalCikis=[];
% her nesnenin max korelasyon de�erini tutar.
%% 

%%KORELASYON HESABLARI    
%%�ABLON E�LE�T�RME


 
for n=1 : Nesneler
    % etiketlenmi� g�r�nt� de karakter ara 
    [r,c] = find(etiketler == n);
    karakter = dilate_karakter_resim(min(r) : max(r),min(c):max(c) );
    karakter = imresize(karakter,[42,24]);
%      figure,imshow(karakter),title('KARAKTER');
    pause(0.2);
    x=[];
    %karakter say�s�n� bucaslduk
    karakterSayisi = size(goruntuler,2);
    %�uan elde etti�imiz nesnenin veritaban�ndaki t�m karakterlerle
    %k�yaslamas�n� yap�yoruz ve korelasyon de�erini elde ediyoruz
    for k=1: karakterSayisi
        y=corr2(goruntuler{1,k},karakter);
        x=[x y];
    end

    % korelasyon de�erleri 0.4 �n alt�nda kalanlar� karakterlikten sil
    if max(x) > 0.4
    enBuyukIndis = find(x==max(x));
    % hangi karakterle e�le�tiyse max indis de�erine bakar o karakter oalcakt�r
    cikisKarakter = cell2mat(goruntuler(2,enBuyukIndis));
    finalCikis = [finalCikis cikisKarakter];    
    end
end
%% NOT BELGES�NE PLAKA YAZIMI

dosya=fopen('plakaKarakterleri.txt','wt');
fprintf(dosya,'%s\n',finalCikis);
fclose(dosya);
winopen('plakaKarakterleri.txt');
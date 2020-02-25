    close all; clear all; clc;
    load imgfildata
    % kullanýcýya dosya seçtirme iþlemi
    [dosya,dosyaYolu] = uigetfile({'*.jpg;*.jpeg;  *.bmp; *.png; *.tif'},'Bir görüntü seçin');
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

    %% KENAR OLAN YERLERÝ DOLDURMA ÝÞLEMÝ BU BÝZE PLAKANIN BÖLGESÝ GOSTERMÝÞ OLACAK 
    
fill_image = imfill(edge_resim,'holes');
%     figure();imshow(fill_image);

    % ÝMERODE ÝLE BAZI PIKSELLERÝ KALDIRMAK 
    erode_resim = fill_image;
  
     for x = 1:3
        erode_resim = imerode(erode_resim,SE);
          
     end
%      figure();imshow(erode_resim);
    %%  


  %BÝNARY GÖRÜNTÜ ÝLE ÇIKARILMIÞ GÖRÜNTÜ ÇARPMIMI  PLAKA KARAKTERÝ NÝ ALMAK
  %ÝÇÝN YAPILDI
    karakter_resim= BW_resim.*erode_resim;
     figure();imshow(karakter_resim);

   % ÞABLON EÞLEÞTÝRME ÝÇÝN KARAKTERLERÝN ÝÇÝNÝN BEYAZ OLMASI GEREKLÝ
  karakter_resim = ~karakter_resim;
  figure();imshow(karakter_resim);
    erode_karakter_resim = imclearborder(karakter_resim);
    
%    figure();imshow(erode_karakter_resim);
    % BAZI GÜRÜLTÜLER KALDIRILDI  
    for x = 1:3
        erode_karakter_resim = imerode(erode_karakter_resim,SE);
    end
    
%  figure();imshow(erode_karakter_resim)

    dilate_karakter_resim = erode_karakter_resim;
  % PLAKA KARAKTERLEÝ DAHA ÝYÝ GÖZÜKMESÝ ÝÇÝN GENÝÞLETÝLDÝ 
    for x = 1:2
        dilate_karakter_resim = imdilate(dilate_karakter_resim,SE);
    end 
    %%   KARAKTERLERÝN BELÝRLENMESÝ 
 figure();imshow(dilate_karakter_resim)
[etiketler ,Nesneler ]= bwlabel(dilate_karakter_resim);

   nesneOzellikler = regionprops(etiketler,'BoundingBox');
for n =1 : Nesneler
   rectangle('Position',nesneOzellikler(n).BoundingBox, 'EdgeColor','r','LineWidth',2);

end
% tüm plaka karakterlerini finalCikis deðiþkeninde saklayacaðým
finalCikis=[];
% her nesnenin max korelasyon deðerini tutar.
%% 

%%KORELASYON HESABLARI    
%%ÞABLON EÞLEÞTÝRME


 
for n=1 : Nesneler
    % etiketlenmiþ görüntü de karakter ara 
    [r,c] = find(etiketler == n);
    karakter = dilate_karakter_resim(min(r) : max(r),min(c):max(c) );
    karakter = imresize(karakter,[42,24]);
%      figure,imshow(karakter),title('KARAKTER');
    pause(0.2);
    x=[];
    %karakter sayýsýný bucaslduk
    karakterSayisi = size(goruntuler,2);
    %þuan elde ettiðimiz nesnenin veritabanýndaki tüm karakterlerle
    %kýyaslamasýný yapýyoruz ve korelasyon deðerini elde ediyoruz
    for k=1: karakterSayisi
        y=corr2(goruntuler{1,k},karakter);
        x=[x y];
    end

    % korelasyon deðerleri 0.4 ün altýnda kalanlarý karakterlikten sil
    if max(x) > 0.4
    enBuyukIndis = find(x==max(x));
    % hangi karakterle eþleþtiyse max indis deðerine bakar o karakter oalcaktýr
    cikisKarakter = cell2mat(goruntuler(2,enBuyukIndis));
    finalCikis = [finalCikis cikisKarakter];    
    end
end
%% NOT BELGESÝNE PLAKA YAZIMI

dosya=fopen('plakaKarakterleri.txt','wt');
fprintf(dosya,'%s\n',finalCikis);
fclose(dosya);
winopen('plakaKarakterleri.txt');
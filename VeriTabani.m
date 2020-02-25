clc; clear; close all;
%% dizini matlab ortam�na  ettik dahil ettik
dizin = dir('VeriSetleri');

dosyaAdlari = {dizin.name};

 dosyaAdlari = dosyaAdlari (3:end);

%2 sat�r 53 s�tunlu (ka� tane dosya varsa) bir cell veri tipi olusturacak
goruntuler = cell(2,length(dosyaAdlari));

for i=1:length(dosyaAdlari)
    
    %%otomatik olarak her seferinde i degeri artacagi icin bir sonrakinin
    %%ismi gelecek ve goruntuler cell degerine aktar�lacak
    goruntuler(1,i) = {imread(['VeriSetleri','\',cell2mat(dosyaAdlari(i))])};

    
    gecici = cell2mat(dosyaAdlari(i));
 
    goruntuler(2,i) = {gecici(1)}; 
end

save('imgfildata.mat','goruntuler')
clear;


 

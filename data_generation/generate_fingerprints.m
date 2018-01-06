fp_dirs = {'x4', 'x5', 'x6', 'target', 'target'};

bg_files = dir('/Users/jansvoboda/Desktop/fingerprint_bgs/');
bg_files = bg_files(4:end); % remove '.', '..' and '.DS_Store'
    
out_dir = '/Volumes/datasets-2/acnn_on_grids/fingerprints_newdata/bg_7/';
out_dir_orig = '/Volumes/datasets-2/acnn_on_grids/fingerprints_newdata/bg_7_orig/';
out_dir_tgts = '/Volumes/datasets-2/acnn_on_grids/fingerprints_newdata/bg_7_targets/';

if ~exist(out_dir)
    mkdir(out_dir);
end
if ~exist(out_dir_orig)
    mkdir(out_dir_orig);
end
if ~exist(out_dir_tgts)
    mkdir(out_dir_tgts);
end

for i=10001:20000
    if exist([out_dir, num2str(i), '.png'], 'file')
        continue
    end
        
    fprintf('Generating sample %d ...\n', i);
    dir_idx = ceil(rand() * length(fp_dirs));
    erode_sz = ceil(rand() * 2);
    
    img = imread(['/Volumes/datasets-2/acnn_on_grids/fingerprints_newdata/', fp_dirs{dir_idx}, '/', num2str(mod(i, 1000) + 1), '.png']);
    imgsz = size(img);
    padl = round(rand() * 100); padr = round(rand() * 100);
    padu = round(rand() * 100); padd = round(rand() * 100);
    img = padarray(img, [padl, padu], max(max(img)), 'pre');
    img = padarray(img, [padr, padd], max(max(img)), 'post');
    img = imresize(img, imgsz);
    img = imerode(img, ones(erode_sz, erode_sz));
    if dir_idx >= 4  
        h = fspecial('motion', rand() * 2 + 4, rand() * 180);
    else
        h = fspecial('motion', rand() * 2, rand() * 180);
    end
    img = imfilter(img, h);
    
    img_tgt = imread(['/Volumes/datasets-2/acnn_on_grids/fingerprints_newdata/target/', num2str(mod(i, 1000) + 1), '.png']);
    img_tgt = padarray(img_tgt, [padl, padu], max(max(img_tgt)), 'pre');
    img_tgt = padarray(img_tgt, [padr, padd], max(max(img_tgt)), 'post');
    img_tgt = imresize(img_tgt, imgsz);
    img_tgt = imerode(img_tgt, ones(erode_sz, erode_sz));

    bg_idx = ceil(rand() * length(bg_files)); 
    img2 = imread(['/Users/jansvoboda/Desktop/fingerprint_bgs/', bg_files(bg_idx).name]);
    
    sx = ceil(rand() * (size(img2, 1) - size(img, 1)));
    sy = ceil(rand() * (size(img2, 2) - size(img, 2)));
    ex = sx + size(img, 1) - 1;
    ey = sy + size(img, 2) - 1; 
    img2_roi = img2(sx:ex, sy:ey, :);
    
    img_fprint = repmat(img, [1, 1, 3]);
    mask_fprint = (img_fprint < max(max(max(img_fprint))));
    img_blend = imfuse(img_fprint, img2_roi, 'blend');
    
    figure(1)
    imshow(img_tgt)
    figure(2)
    imshow(img_blend)
    
    break;
    imwrite(img_blend, [out_dir, num2str(i), '.png']);
    imwrite(img, [out_dir_orig, num2str(i), '.png']);
    imwrite(img_tgt, [out_dir_tgts, num2str(i), '.png']);
end
fprintf('Done.\n', i);
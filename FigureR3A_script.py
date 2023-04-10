# Johann V. Hemmer
# 25 Feb 2023
# Crop and process videos taken with the phone adapter

import numpy as np
import cv2
import os

# File name
file = 'IMG_2082.MOV'
dir_path = os.path.dirname(os.path.realpath(__file__))
os.chdir(dir_path)

video = cv2.VideoCapture(file)

width_frame = int(video.get(cv2.CAP_PROP_FRAME_WIDTH))
height_frame = int(video.get(cv2.CAP_PROP_FRAME_HEIGHT))
rate_frame = video.get(cv2.CAP_PROP_FPS)
total_frame = video.get(cv2.CAP_PROP_FRAME_COUNT)

w, h = 512, 512
x, y = 480-w//2, 1350-h//2

# 377, 1290
# 408, 1255

fourcc = cv2.VideoWriter_fourcc(*'XVID')

# new_path = dir_path + '\\Output\\'
# if not os.path.exists(new_path):
#     os.makedirs(new_path)

output = cv2.VideoWriter(os.path.splitext(file)[0]+'_processed.mov', fourcc, rate_frame, (w, h))

f = 0
while (video.isOpened()):
    f += 1
    print(f'Frame {f} of {int(total_frame+1)}.')

    ret, frame = video.read()

    if ret:
        # Cropping the frame
        cropped_frame = frame[y:y+h, x:x+w]

        # Deleting blue and green channels
        red_frame = cropped_frame.copy()
        red_frame[:, :, 0] = 0
        red_frame[:, :, 1] = 0

        # Sharpening the frame by gaussian blur subtraction
        blurred_frame = cv2.GaussianBlur(red_frame, (0, 0), 2)
        sharp_frame = cv2.addWeighted(red_frame, 1.6, blurred_frame, -1, 0)

        # Increasing contrast by dynamic range expansion
        rows, cols, _ = cropped_frame.shape

        power = 1.5
        gain = 2

        contrast_frame = sharp_frame.copy()
        for i in range(rows):
            for j in range(cols):
                contrast_frame[i, j, 2] = gain*255*((contrast_frame[i, j, 2]/255)**power)
                if contrast_frame[i, j, 2] > 255:
                    contrast_frame[i, j, 2] = int(255)
                else:
                    contrast_frame[i, j, 2] = int(contrast_frame[i, j, 2])

        output.write(contrast_frame)

        cv2.imshow('Processed', contrast_frame)

        # Press "Q" to abort
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    else:
        break

video.release()
output.release()
cv2.destroyAllWindows()

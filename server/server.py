import os

import cv2
import firebase_admin
import mediapipe as mp
from firebase_admin import credentials, storage
from flask import request, jsonify, Flask


def upload_video(video_path):
    bucket_name = 'codingminds.appspot.com'

    fb_cred = 'key.json'
    cred = credentials.Certificate(fb_cred)
    firebase_admin.initialize_app(cred, {
        'storageBucket': bucket_name
    })
    bucket = storage.bucket()
    blob = bucket.blob(video_path)

    if blob.exists():
        print('This file already exists on cloud.')
        print(blob.public_url)
        return blob.public_url
    else:
        outfile = video_path
        blob.upload_from_filename(outfile)
        with open(outfile, 'rb') as fp:
            blob.upload_from_file(fp)
        print('This file is uploaded to cloud.')
        blob.make_public()
        return blob.public_url


def process_videos(video):
    mp_drawing = mp.solutions.drawing_utils
    mp_drawing_styles = mp.solutions.drawing_styles
    mp_pose = mp.solutions.pose

    output_path = 'output.mp4'
    cap = cv2.VideoCapture(video)
    fps = cap.get(cv2.CAP_PROP_FPS)
    width = 720  # float `width`
    height = 480  # float `height`
    print(width, height)
    pose = mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5)
    out = cv2.VideoWriter(output_path, cv2.VideoWriter_fourcc('m', 'p', '4', 'v'), fps, (width, height))

    while cap.isOpened():
        success, image = cap.read()

        if not success:
            print("Ignoring empty camera frame.")
            # If loading a video, use 'break' instead of 'continue'.
            break

        results = pose.process(image)

        if results.pose_landmarks != None:

            # Draw the pose annotation on the image.
            mp_drawing.draw_landmarks(
                image,
                results.pose_landmarks,
                mp_pose.POSE_CONNECTIONS,
                landmark_drawing_spec=mp_drawing_styles.get_default_pose_landmarks_style())
        else:
            continue
        out.write(image)
        

        if cv2.waitKey(5) & 0xFF == 27:
            break
    cap.release()

    out.release()
    print("Released")
    final_url = upload_video(output_path)
    return final_url


app = Flask(__name__)
app.config['UPLOAD_EXTENSIONS'] = ['.mp4', '.mov']


@app.route('/')
def home():
    return 'Sample server'


@app.route('/analyze', methods=['GET', 'POST'])  # route for uploading image
def edit_video():
    uploaded_video = request.files.getlist("video1")[0]

    print(uploaded_video.filename)
    video1_filename = uploaded_video.filename

    if video1_filename != '':

        _, video_file_ext = os.path.splitext(video1_filename)
        uploaded_video.save(video1_filename)
        links = process_videos(video1_filename)

        if os.path.isfile(video1_filename):
            os.remove(video1_filename)

        return jsonify(links)


if __name__ == "__main__":
    app.run(host='0.0.0.0')

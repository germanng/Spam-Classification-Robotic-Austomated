from flask import Flask, request, render_template, jsonify
import joblib
import subprocess

app = Flask(__name__)

# Load the model and CountVectorizer
model = joblib.load('mlp_classifier_model.pkl')
vectorizer = joblib.load('count_vectorizer.pkl')

@app.route('/', methods=['GET'])
def home():
    return render_template('index.html')

@app.route('/classify', methods=['POST'])
def classify_text():
    text = request.form['text']
    transformed_text = vectorizer.transform([text])
    prediction = model.predict(transformed_text)
    result = 'Spam' if prediction[0] == 1 else 'Not Spam'
    return jsonify({'classification': result})

@app.route('/start_validation', methods=['GET'])
def start_validation():
    try:
        # Running the Robot Framework script
        subprocess.run(["robot", "classify_text_files.robot"])
        return "Validation process started. Check console for progress."
    except Exception as e:
        return f"Error occurred: {e}"

if __name__ == '__main__':
    app.run(debug=True)

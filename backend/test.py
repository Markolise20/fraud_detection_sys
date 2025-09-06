import google.generativeai as genai
genai.configure(api_key="AIzaSyAY9BOgUJHzgGt-WLP9c3m8rE9QDqfebqg")
model = genai.GenerativeModel('gemini-2.0-flash-lite')
response = model.generate_content("Who is ronaldo")
print(response.text)
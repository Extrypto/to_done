// Файл: ai_subtask_creator.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AISubtaskCreator {
  static Future<List<String>> createSubtasks(
      String taskTitle, String apiKey) async {
    String url = "https://api.proxyapi.ru/openai/v1/chat/completions";
    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    };
    var data = json.encode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "user",
          "content":
              "Сделай декомпозицию задачи \"$taskTitle\". Для простой задачи не более 3-х шагов. Если задача средней сложности: 4-5 пунктов, а если сложная: 6-10 пунктов. Очевидные пункты следует исключить."
        }
      ],
      "temperature": 0.7
    });

    try {
      var response =
          await http.post(Uri.parse(url), headers: headers, body: data);
      if (response.statusCode == 200) {
        var utf8Response =
            utf8.decode(response.bodyBytes); // Декодируем ответ в UTF-8
        var completion =
            json.decode(utf8Response)['choices'][0]['message']['content'];
        RegExp regExp = RegExp(r'\d+\. (.+)');
        return regExp
            .allMatches(completion)
            .map((match) => match.group(1)!.trim())
            .toList();
      } else {
        print("Ошибка при запросе: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Исключение при запросе: $e");
      return [];
    }
  }
}

import UIKit
import CryptoKit

class CreatingUrl {

    //Метод для Hash
    private func MD5(string: String) -> String {
        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }

    //Получение ссылки монет
    func getUrlCoin() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.coincap.io"
        components.path = "/v2/assets"

        let url = components.url
        return url
    }

    //Получение ссылки Marvel
    func getUrlMarvel() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "gateway.marvel.com"
        components.path = "/v1/public/characters"

        let publicKey = "7b8e485606503dda985b5811626331c2"
        let privateKey = "9f71fa61e8a9dec9e7904cd00c41ded68e76d4cf"
        let ts = String(Date().timeIntervalSince1970)
        let hash = MD5(string: "\(ts)\(privateKey)\(publicKey)")

        let queryItemTs = URLQueryItem(name: "ts", value: ts)
        let queryItemApiKey = URLQueryItem(name: "apikey", value: publicKey)
        let queryItemHash = URLQueryItem(name: "hash", value: hash)

        components.queryItems = [queryItemTs, queryItemApiKey, queryItemHash]

        let url = components.url
        return url
    }
}

class WorkingWithUrlRequest {

    //Получение данных
    func getData(urlRequest: URL?) {
        guard let url = urlRequest else {
            print("Неверный url")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in

            if error != nil {
                print("Ошибка - \(String(describing: error?.localizedDescription))")
            }

            guard let httpResponse = response as? HTTPURLResponse else { return }

            switch httpResponse.statusCode {
            case 200:
                print("\nКод ответа от сервера Response: \n\(httpResponse)")

                guard let data = data else { return }
                let dataAsString = String(data: data, encoding: .utf8)

                print("\nДанные, пришедшие с сервера: \n\(String(describing: dataAsString))")
            case 409:
                print("Status Code: \(httpResponse.statusCode). Missing API Key, Missing Hash or Missing Timestamp    ")
            case 401:
                print("Status Code: \(httpResponse.statusCode). Invalid Referer or Invalid Hash")
            case 405:
                print("Status Code: \(httpResponse.statusCode). Method Not Allowed")
            case 403:
                print("Status Code: \(httpResponse.statusCode). Forbidden")
            default:
                print("Статус ошибки с сервера: \(httpResponse.statusCode)\n")
            }
        }.resume()
    }
}

let creatingUrl = CreatingUrl()
let workingWithUrlRequest = WorkingWithUrlRequest()

let urlCoin = creatingUrl.getUrlCoin()
let urlMarvel = creatingUrl.getUrlMarvel()

//Проверка
//workingWithUrlRequest.getData(urlRequest: urlCoin)
workingWithUrlRequest.getData(urlRequest: urlMarvel)

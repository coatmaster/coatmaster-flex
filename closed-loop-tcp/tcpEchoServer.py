import socket

HOST = '0.0.0.0'  # Listen on all interfaces
PORT = 1234       # Port to listen on
DELIMITER = ';'  # Message delimiter
def parse_message(message):
    """Parses messages in the format: CMD?key1=value1&key2=value2"""
    try:
        parts = message.strip().split('?')
        command = parts[0]
        args = {}

        if len(parts) >= 1:
            arguments = parts[1].split('&')
            
            for part in arguments:
                if '=' in part:
                    key, value = part.split('=', 1)
                    args[key] = value
        return command, args
    except Exception as e:
        print(f"Error parsing message '{message}': {e}")
        return None, {}

def main():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind((HOST, PORT))
        s.listen()
        print(f"Server listening on {HOST}:{PORT}")
        print(f"Using delimiter: {repr(DELIMITER)}")

        while True:
            conn, addr = s.accept()
            with conn:
                print(f"Connected by {addr}")
                buffer = ""  # Buffer to accumulate incomplete messages

                while True:
                    try:
                        data = conn.recv(1024)
                        print(f"received: {data}")
                        if not data:
                            break

                        buffer += data.decode('utf-8', errors='ignore')
                        

                        while DELIMITER in buffer:
                            # Split at first delimiter
                            message, buffer = buffer.split(DELIMITER, 1)

                            print(f"Received complete message: {message}")

                            command, args = parse_message(message)
                            print(f"received cmd:{command}")
                            for arg in args.keys():
                                print(f"{arg} -> {args[arg]}")

                            # Echo the message back with delimiter
                            response = f"Echo:{message}{DELIMITER}"
                            conn.sendall(response.encode('utf-8'))
                            print(f"Sent: {response.strip()}")

                    except Exception as e:
                        print(f"Error handling message: {e}")
                        break
                        
if __name__ == "__main__":
    main()

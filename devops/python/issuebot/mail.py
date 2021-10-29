import smtplib
from email.header import Header
from email.mime.text import MIMEText
from email.utils import formataddr, parseaddr


class mail():
    def __init__(
            self,
            smtp_server: str,
            port: int,
            password: str,
            subject: str,
            from_addr: str,
            to: str):
        self._subject = subject
        self._from = from_addr
        self._to = to
        self._password = password
        self._smtp_server = smtp_server
        self._port = port

    def _format_addr(self, addr: str):
        name, addr = parseaddr(addr)
        # name may include chinese
        return formataddr((Header(name, 'utf-8').encode(), addr))

    def set_msg(self, body: str, subtype='html'):
        # support html format
        self._msg = MIMEText(body, subtype, 'utf-8')
        self._msg['From'] = self._format_addr(self._from)
        self._msg['To'] = self._format_addr(self.to)
        self._msg['Subject'] = Header('ST Issue', 'utf-8').encode()

        # msg = MIMEText('<html><body><h1>Hello</h1>' +
        # '<p>send by <a href="http://www.python.org">Python</a>...</p>' +
        # '</body></html>', 'html', 'utf-8')

    def send(self):
        server = smtplib.SMTP(self._smtp_server, self._port)
        # print debug information
        # server.set_debuglevel(1)
        server.login(self._from, self._password)
        server.sendmail(self._from, self._to, self._msg.as_string())
        server.quit()

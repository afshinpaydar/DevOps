import tornado.ioloop
import tornado.gen
import time
from nats.io.client import Client as NATS

def main():
    nc = NATS()

    # Establish connection to the server.
    yield nc.connect("nats-nats.apps.soshyant.local")

    @tornado.gen.coroutine
    def message_handler(msg):
        subject = msg.subject
        data = msg.data
        print("[Received on '{}'] : {}".format(subject, data.decode()))

    # Simple async subscriber
    sid = yield nc.subscribe("foo", cb=message_handler)

    # Stop receiving after 2 messages.
    yield nc.auto_unsubscribe(sid, 2)
    yield nc.publish("foo", b'Hello')
    yield nc.publish("foo", b'World')
    yield nc.publish("foo", b'!!!!!')

    # Request/Response
    @tornado.gen.coroutine
    def help_request_handler(msg):
        print("[Received on '{}']: {}".format(msg.subject, msg.data))
        yield nc.publish(msg.reply, "OK, I can help!")

    # Susbcription using distributed queue named 'workers'
    sid = yield nc.subscribe("help", "workers", help_request_handler)

    try:
        # Send a request and expect a single response
        # and trigger timeout if not faster than 200 ms.
        msg = yield nc.request("help", b"Hi, need help!", timeout=0.2)
        print("[Response]: %s" % msg.data)
    except tornado.gen.TimeoutError:
        print("Timeout!")

    # Remove interest in subscription.
    yield nc.unsubscribe(sid)

    # Terminate connection to NATS.
    yield nc.close()

if __name__ == '__main__':
    tornado.ioloop.IOLoop.current().run_sync(main)

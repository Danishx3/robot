import math
import time
import threading
import pygame

class Face:
    def __init__(self, width=480, height=320):
        pygame.init()
        self.screen = pygame.display.set_mode((width, height))
        pygame.display.set_caption("Mini Robot Face")
        self.w, self.h = width, height
        self.expression = "happy"
        self.running = True
        self._lock = threading.Lock()

    def set(self, expression):
        with self._lock:
            self.expression = expression

    def draw(self):
        self.screen.fill((8, 10, 15))
        with self._lock:
            exp = self.expression

        cx1, cx2 = self.w * 0.32, self.w * 0.68
        cy = self.h * 0.42

        if exp == "blink":
            self._eye(cx1, cy, 52, 7)
            self._eye(cx2, cy, 52, 7)
        elif exp == "sad":
            self._sad_eye(cx1, cy)
            self._sad_eye(cx2, cy)
        elif exp == "surprised":
            self._eye(cx1, cy, 48, 48)
            self._eye(cx2, cy, 48, 48)
        elif exp == "thinking":
            self._eye(cx1, cy, 38, 38)
            self._eye(cx2, cy, 38, 38)
        else:
            self._eye(cx1, cy, 46, 46)
            self._eye(cx2, cy, 46, 46)

        if exp == "sad":
            pygame.draw.arc(self.screen, (235, 245, 255),
                            (self.w*.40, self.h*.55, self.w*.20, 60),
                            math.pi, 2*math.pi, 7)
        elif exp == "surprised":
            pygame.draw.circle(self.screen, (235,245,255),
                               (int(self.w*.5), int(self.h*.65)), 22, 7)
        elif exp == "thinking":
            pygame.draw.line(self.screen, (235,245,255),
                             (self.w*.44, self.h*.65),
                             (self.w*.50, self.h*.62), 6)
            pygame.draw.line(self.screen, (235,245,255),
                             (self.w*.50, self.h*.62),
                             (self.w*.56, self.h*.65), 6)
        else:
            pygame.draw.arc(self.screen, (235,245,255),
                            (self.w*.40, self.h*.55, self.w*.20, 65),
                            math.pi, 2*math.pi, 7)

        pygame.display.flip()

    def _eye(self, x, y, rx, ry):
        pygame.draw.ellipse(self.screen, (235,245,255),
                            (int(x-rx), int(y-ry), int(rx*2), int(ry*2)))

    def _sad_eye(self, x, y):
        pygame.draw.arc(self.screen, (235,245,255),
                        (int(x-45), int(y-25), 90, 55),
                        0, math.pi, 7)

    def loop(self):
        clock = pygame.time.Clock()
        while self.running:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    self.running = False
            self.draw()
            clock.tick(30)

    def stop(self):
        self.running = False
        pygame.quit()

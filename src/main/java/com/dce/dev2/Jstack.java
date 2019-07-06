package main.java.com.dce.dev2;

import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

/**
 * Jstack
 */
public class Jstack {
    public static Executor executor = Executors.newFixedThreadPool(5);
    public static Object lock = new Object();
    static class Task implements Runnable {
        @Override
        public void run() {
            synchronized(lock) {
                int i = 0;
                while (true) {
                    i++;
                    i--;
                }
            }
        }
    }

    public static void main(String[] args) {
        Task t1 = new Task();
        Task t2 = new Task();
        executor.execute(t1);
        executor.execute(t2);
    }
}

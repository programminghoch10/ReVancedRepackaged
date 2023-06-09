package com.programminghoch10.revancedandroidcli;

import java.lang.reflect.Method;
import app.revanced.cli.main.MainKt;

public class MainCommand{
    public static void main(String[] args) {
        System.out.println("sysout");
        System.err.println("syserr");
        Runtime runtime = Runtime.getRuntime();
        long maxMemory = runtime.maxMemory();
        System.err.println("Memory limit: " + maxMemory);
        try {
            System.err.println("property");
            System.setProperty("java.io.tmpdir", "/data/local/tmp");
            System.err.println("class");
            Method main = MainKt.class.getMethod("main", String[].class);
            System.err.println("invoke");
            main.invoke(null, (Object) args);
            System.err.println("end");
            System.exit(0);
        } catch (Exception e) {
            System.err.println("error");
            e.printStackTrace();
            System.exit(1);
        }
    }
    
}

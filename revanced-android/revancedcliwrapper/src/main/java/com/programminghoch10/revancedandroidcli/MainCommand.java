package com.programminghoch10.revancedandroidcli;

import app.revanced.cli.command.MainCommandKt;

public class MainCommand{
    public static void main(String[] args) {
        //System.out.println("sysout");
        //System.err.println("syserr");
        Runtime runtime = Runtime.getRuntime();
        long maxMemory = runtime.maxMemory();
        //System.err.println("Memory limit: " + maxMemory);
        try {
            //System.err.println("property");
            System.setProperty("java.io.tmpdir", "/data/local/tmp");
            //System.err.println("invoke");
            MainCommandKt.main(args);
            //System.err.println("end");
            System.exit(0);
        } catch (Exception e) {
            System.err.println("error");
            e.printStackTrace();
            System.exit(1);
        }
    }
    
}

#!/bin/bash
# Stop the application using PM2
pm2 stop MyWebApp || true
pm2 delete MyWebApp || true

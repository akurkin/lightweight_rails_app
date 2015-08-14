FROM rails:onbuild

CMD ["bundle", "exec", "unicorn", "-p", "3000"]
from django.core.management.base import BaseCommand, CommandError
from codespeed.models import Report


class Command(BaseCommand):
    help = 'Recalculates all reports'

    def handle(self, *args, **options):
        n = 0
        for report in Report.objects.all():
            self.stdout.write('Recalculating report %s...' % report)
            report.save()
            n += 1
        self.stdout.write('Successfully recalculated %d reports.' % n)
